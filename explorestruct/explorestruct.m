%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CRC - ExploreStruct v1.2, 
% MatLab Utility for exploring structures and plotting their fields
% Syntax: explorestruct(S), where S is structure, array of strctures or nested structures
%
% - Bugfixes for version R2012a by Luke Plausin 2015
%   - Muted warnings for set/java objects
%   - Changed code structure to use form handle for get/set UserData calls
%   - Fixed icons not loading for some reason
%
% Hassan Lahdili (hassan.lahdili@crc.ca)
% Communications Research Centre (CRC) | Advanced Audio Systems (AAS)
% www.crc.ca | www.crc.ca/aas
% Ottawa. Canada
% CRC Advanced Audio Systems - Ottawa � 2004-2005
% 16/02/2005
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function explorestruct(varargin)

if ~isstruct(varargin{:})
    msgerror = strcat('''',inputname(1),''''' is not a structure!!');
    error(msgerror);
end

import javax.swing.*;

warning('off', 'MATLAB:hg:JavaSetHGProperty');
h = figure('Units', 'normalized', 'Color', [.925 .914 .847], 'Position', [.15 .15 .7 .6]);
set(h,'NextPlot', 'add', 'NumberTitle', 'off', 'Toolbar', 'figure')
name = inputname(1);
fig_name = 'explorestruct';
fig_name = strcat(fig_name, ': ', name);
set(h,  'Name', fig_name);
root = uitreenode('v0',name, name, [], false);
tree = uitree('v0', h,'Root', root,'ExpandFcn', @(obj, ev)myExpfcn4(obj, ev, h));
pause(0.1);
set(tree, 'Units', 'normalized', 'position', [0 0 0.35 1])
set(tree, 'NodeWillExpandCallback', @(obj, ev) nodeWillExpand_cb4(obj, ev, h));
set(tree, 'NodeSelectedCallback', @(obj, ev)nodeSelected_cb4(obj, ev, h));
tmp = tree. FigureComponent;
cell_Data = cell(2,1);
cell_Data{1} = varargin{:};
%set(tmp, 'UserData', cell_Data);
set(h, 'UserData', cell_Data);
haxes = axes('Units', 'normalized','Position', [.491 .182 .434 .653], 'Box', 'on', 'XTick', [], 'YTick', []);
haxes2 = axes('Units', 'normalized','Position', [.873 .055 .06 .05],  'XTick', [], 'YTick', []);
logo = load ('Stbrowser');
image(logo.A, 'Parent', haxes2);
set(haxes2,  'visible','off');
pb1 = uicontrol('String', 'Plot Selected', 'Units', 'normalized',...
                        'Position', [.36 .6 .086 .083] , 'callback', @(obj, ev) plotselected_cb(obj, ev, h),...
                        'TooltipString', ' Plot Selection ');
pb2 = uicontrol('String', 'Disp Selected', 'Units', 'normalized',...
                        'Position', [.36 .464 .086 .083], 'callback', @(obj, ev) displayselected_cb(obj, ev, h),...
                        'TooltipString', ' Display Selection in command ');
pb3 = uicontrol('String', 'Export', 'Units', 'normalized',...
                        'Position', [.36 .328 .086 .083], 'callback', @(obj, ev) exportselected_cb(obj, ev, h),...
                        'TooltipString', ' Export Selection to workspace ');
                    
txt1 = uicontrol('String', '', 'Units', 'normalized', 'Style', 'Edit',...
                            'Position', [.491 .915 .145 .034], 'BackgroundColor',  [.925 .914 .847]);
txt2 = uicontrol('String', '', 'Units', 'normalized', 'Style', 'Edit',...
                            'Position', [.636 .915 .145 .034], 'BackgroundColor',  [.925 .914 .847]);
txt3 = uicontrol('String', '', 'Units', 'normalized', 'Style', 'Edit',...
                            'Position', [.781 .915 .145 .034], 'BackgroundColor',  [.925 .914 .847]);
                        
txt4 = uicontrol('String', 'CRC-ExploreStruct', 'Units', 'normalized', 'Style', 'text',...
                            'Position', [.547 .065 .29 .046], 'ForeGroundColor', [0.2 0.4 1],...
                            'FontSize', 18,'FontWeight', 'bold','FontAngle', 'italic');
col1 = uicontrol('String', 'Name', 'Units', 'normalized', 'Style', 'Text',...
                            'Position', [.491 .949 .145 .03], 'BackgroundColor',  [.925 .914 .847]);
col2 = uicontrol('String', 'Size', 'Units', 'normalized', 'Style', 'Text',...
                            'Position', [.636 .949 .145 .03], 'BackgroundColor',  [.925 .914 .847]);
col3 = uicontrol('String', 'Class', 'Units', 'normalized', 'Style', 'Text',...
                            'Position', [.781 .949 .145 .03], 'BackgroundColor',  [.925 .914 .847]);
label = uicontrol('String', 'Selected''s info', 'Units', 'normalized', 'Style', 'Text',...
                            'Position', [.375 .91 .1 .034], 'BackgroundColor',  [.925 .914 .847]);
%test = get(tmp, 'UserData');
test = get(h, 'UserData');
cMenu1 = JMenuItem('Plot selected');
set(cMenu1, 'ActionPerformedCallback', @(obj, ev) cMenu1_cb(obj, ev, h));
cMenu2 = JMenuItem('Display selected');
set(cMenu2, 'ActionPerformedCallback', @(obj, ev) cMenu2_cb(obj, ev, h));
cMenu3 = JMenuItem('Export selected');
set(cMenu3, 'ActionPerformedCallback', @(obj, ev) cMenu3_cb(obj, ev, h));
pUpMenu = JPopupMenu;
pUpMenu.add(cMenu1);
pUpMenu.add(cMenu2);
pUpMenu.add(cMenu3);
cmenu = uicontextmenu;
%set(root,'UIContextMenu', cmenu);
set(tmp,'UIContextMenu', cmenu);
t = tree.Tree;
set(t, 'MousePressedCallback', @mouse_cb);

warning('on', 'MATLAB:hg:JavaSetHGProperty');
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mouse Pressed Handler
    function mouse_cb(h, ev)        
        if ev.getModifiers()== ev.META_MASK
            pUpMenu.show(t, ev.getX, ev.getY);
            pUpMenu.repaint;
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function plotselected_cb(obj, ev, h)
        tmp =  tree. FigureComponent;
        %S = get(tmp, 'UserData');
        S = get(h, 'UserData');
        s = S{1};
        cNode = S{2};
        [val, plotted, cNode] = getcNodevalue(cNode, s);
        
        if isnumeric(val) & length(val)>1
            if isreal(val)
                plot(haxes,val)
                set(haxes, 'XLim', [1 length(val)])
                title(haxes, plotted)
            else
                plot(haxes,abs(val))
                set(haxes, 'XLim', [1 length(val)])
                title(haxes, plotted)
                legend(haxes,strcat('abs of (',plotted, ')'))
            end
        else
            errordlg('variable to be plotted should be numeric with length > 1')
        end

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function displayselected_cb(obj, ev, h)
        tmp =  tree. FigureComponent;
        %S = get(tmp, 'UserData');
        S = get(h, 'UserData');
        s = S{1};
        cNode = S{2};
        [val, displayed, cNode] = getcNodevalue(cNode, s);
        disp(strcat(displayed, '='))
        disp(val)
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function exportselected_cb(obj, ev, h)
        %Exporting data from a tree to the MATLAB workspace 
        tmp =  tree. FigureComponent;
        %S = get(tmp, 'UserData');
        S = get(h, 'UserData');
        s = S{1};
        cNode = S{2};
        val = s;
        [val, exported, cNode] = getcNodevalue(cNode, s);
        disp(strcat(exported, ' is assigned to V in workspace'))
        assignin('base', 'V', val);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cMenu1_cb(obj, ev, h)
        plotselected_cb(obj, ev, h);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cMenu2_cb(obj, ev, h)
        displayselected_cb(obj, ev, h);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cMenu3_cb(obj, ev, h)
        exportselected_cb(obj, ev, h);
    end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function cNode = nodeSelected_cb4(tree,ev,h)
        cNode = ev.getCurrentNode;
        tmp = tree.FigureComponent;
       % cell_Data =get(tmp, 'UserData');
        cell_Data =get(h, 'UserData');
        cell_Data{2} = cNode;
        s = cell_Data{1};
        val = s;
        plotted = cNode.getValue;
        selected = plotted;
        [val, plotted, cNode] = getcNodevalue(cNode, val);
        set(txt1, 'string', selected)
        set(txt2, 'string', strcat(num2str(size(val,1)),'x',num2str(size(val,2))) )
        set(txt3, 'string', class(val))        
        %set(tmp, 'UserData', cell_Data);    
        set(h, 'UserData', cell_Data);
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function nodes = myExpfcn4(tree,value,h)    
        try
            tmp = tree. FigureComponent;
            %S= get(tmp, 'UserData');
            S= get(h, 'UserData');
            s = S{1};
            cNode = S{2};
            [val, cNode] = getcNodevalue(cNode, s);
            fnames = fieldnames(val);
            
            mfp = mfilename('fullpath');
            mfp = mfp(1:length(mfp)-length(mfilename));
            pth = [mfp, 'exp_struct_icons\'];
            %%
            L = length(val);
            count = 0;
            if L > 1
                 iconpath =[pth,'struct_icon.GIF'];
                for J = 1:L
                    count = count + 1;
                    cNode = S{2};
                    fname = strcat(cNode.getValue, '(', num2str(J),')');
                    nodes(count) =  uitreenode('v0', fname, fname, iconpath, 0);
                end
            else
                %%
            for i=1:length(fnames)           
                count = count + 1;
                x = getfield(val,fnames{i});
                if isstruct(x)
                    if length(x) > 1
                        iconpath =[pth,'structarray_icon.GIF'];
                    else
                         iconpath =[pth,'struct_icon.GIF'];
                    end                    
                elseif isnumeric(x)
                    iconpath =[pth,'double_icon.GIF'];
                elseif iscell(x)
                    iconpath =[pth,'cell_icon.GIF'];
                elseif ischar(x)
                    iconpath =[pth,'char_icon.GIF'];
                elseif islogical(x)
                    iconpath =[pth,'logic_icon.GIF'];
                elseif isobject(x)
                    iconpath =[pth,'obj_icon.GIF'];
                else
                    iconpath =[pth,'unknown_icon.GIF'];
                end
                nodes(count) = uitreenode('v0',fnames{i}, fnames{i}, iconpath, ~isstruct(x));
            end
            end

        catch
            error(['The uitree node type is not recognized. ' ...
                ' You may need to define an ExpandFcn for the nodes.']);
        end
        if (count == 0)
            nodes = [];
        end
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function cNode = nodeWillExpand_cb4(tree,ev, h)
        cNode = ev.getCurrentNode;
        %tmp = tree.FigureComponent;
        %cell_Data =get(tmp, 'UserData');
        cell_Data =get(h, 'UserData');
        cell_Data{2} = cNode;
        %set(tmp, 'UserData', cell_Data);
        set(h, 'UserData', cell_Data);
    end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [val, displayed, cNode] = getcNodevalue(cNode, s)
        
        fields = {};        
        while cNode.getLevel ~=0
            fields = [fields; cNode.getValue];
            c = findstr(cNode.getValue, '(');
            if ~isempty(c) && cNode.getLevel ~=0
                cNode = cNode.getParent;
            end
            
            if  cNode.getLevel ==0, break; end
            cNode = cNode.getParent;
        end
        val = s;
        if ~isempty(fields)
            L=length(fields);
            displayed = fields{L};
            for j = L-1:-1:1, displayed = strcat(displayed, '.', fields{j}); end
            for i=L:-1:1
                field = fields{i};            
                d = findstr(field,'(');
                if ~isempty(d)
                    d_e = findstr(field,')'); 
                    idx = str2num(field(d+1:d_e-1));
                    field = field(1:d-1);
                    if (strcmp(field, cNode.getValue))
                        val = val(idx);
                    else
                        val = getfield(val, field, {idx});
                    end
                else
                    val = getfield(val, field);
                end
            end
        else
            displayed = cNode.getValue;
            return;
        end
    end
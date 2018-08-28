function CloseFig(~,~)

q = questdlg('Are you sure you want to quit?','Quit Warning','Cancel');

switch q
    case 'Yes'
        delete(gcbo)
    case 'No'
        return
end

end
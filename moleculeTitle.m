%Create the title according to the given variables
function moleculeTitle(molecule, coordinates, cameraside)
switch cameraside
    case 1
        title(strcat(['Molecule No. ',num2str(molecule),' of ', ...
            num2str(size(coordinates,1)),' Donor coordinates: ', ...
            num2str(coordinates(molecule,1)),'/', ...
            num2str(512-coordinates(molecule,2))]));
    case 2
        title(strcat(['Molecule No. ',num2str(molecule),' of ',...
            num2str(size(coordinates,1)),' Acceptor coordinates: ',...
            num2str(coordinates(molecule,1)),'/', ...
            num2str(512-coordinates(molecule,2))]));
    case 3
        title(strcat(['Molecule No. ',num2str(molecule),' of ', ...
            num2str(size(coordinates,1)),' Donor coordinates: ', ...
            num2str(coordinates(molecule,1)),'/', ...
            num2str(coordinates(molecule,2)), ...
            ' Acceptor coordinates: ', ...
            num2str(coordinates(molecule,3)),'/', ...
            num2str(coordinates(molecule,4))]));
end
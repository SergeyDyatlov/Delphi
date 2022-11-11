unit TmxMap;

interface

uses
  Xml.XMLIntf, XMLDoc, TmxLayer, TmxTileLayer, TmxTileset, TmxObjectGroup,
  System.Generics.Collections;

type
  TTmxMap = class
  private
    FFilePath: string;
    FWidth: Integer;
    FHeight: Integer;
    FTileWidth: Integer;
    FTileHeight: Integer;
    FTilesets: TObjectDictionary<Cardinal, TTmxTileset>;
    FLayers: TObjectList<TTmxLayer>;
    procedure ParseMap(Node: IXMLNode);
    procedure ParseTileset(Node: IXMLNode);
    procedure ParseTilesetTile(Node: IXMLNode; Tileset: TTmxTileset);
    procedure ParseTilesetImage(Node: IXMLNode; Tileset: TTmxTileset);
    procedure ParseTileLayer(Node: IXMLNode);
    procedure ParseTileLayerData(Node: IXMLNode; Layer: TTmxTileLayer);
    procedure DecodeBinaryLayerData(Layer: TTmxTileLayer; Text: string);
    procedure DecodeCSVLayerData(Layer: TTmxTileLayer; Text: string);
    function GetTilesetByGid(Gid: Cardinal): TTmxTileset;
    procedure ParseObjectGroup(Node: IXMLNode);
    procedure ParseObjectGroupObject(Node: IXMLNode; Group: TTmxObjectGroup);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const FileName: string);
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property TileWidth: Integer read FTileWidth;
    property TileHeight: Integer read FTileHeight;
    property Tilesets: TObjectDictionary<Cardinal, TTmxTileset> read FTilesets;
    property Layers: TObjectList<TTmxLayer> read FLayers;
  end;

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, TmxImage;

{ TTmxMapReader }

constructor TTmxMap.Create;
begin
  FTilesets := TObjectDictionary<Cardinal, TTmxTileset>.Create([doOwnsValues]);
  FLayers := TObjectList<TTmxLayer>.Create(True);
end;

procedure TTmxMap.DecodeBinaryLayerData(Layer: TTmxTileLayer; Text: string);
begin

end;

procedure TTmxMap.DecodeCSVLayerData(Layer: TTmxTileLayer; Text: string);
var
  List: TStringList;
  Y, X: Integer;
  Tokens: TArray<string>;
  Gid, TileId: Cardinal;
  Tileset: TTmxTileset;
  Cell: TTmxCell;
begin
  List := TStringList.Create;
  try
    List.Text := Text;
    List.Delete(0);

    for Y := 0 to Layer.Height - 1 do
    begin
      Tokens := List[Y].Split([',']);
      for X := 0 to Layer.Width - 1 do
      begin
        Gid := Tokens[X].ToInteger;
        if Gid <> 0 then
        begin
          Tileset := GetTilesetByGid(Gid);
          TileId := Gid - Tileset.FirstGId;
          Cell := TTmxCell.Create(Tileset, TileId);
          Layer.SetCell(Cell, X, Y);
        end;
      end;
    end;
  finally
    List.Free;
  end;
end;

destructor TTmxMap.Destroy;
begin
  FLayers.Free;
  FTilesets.Free;
  inherited;
end;

function TTmxMap.GetTilesetByGid(Gid: Cardinal): TTmxTileset;
var
  Keys: TArray<Cardinal>;
  Tileset: TTmxTileset;
  I: Cardinal;
begin
  Result := nil;
  Keys := FTilesets.Keys.ToArray;
  TArray.Sort<Cardinal>(Keys);
  for I := Length(Keys) - 1 downto 0 do
  begin
    Tileset := FTilesets[Keys[I]];
    if Tileset.FirstGId <= Gid then
      Exit(Tileset);
  end;
end;

procedure TTmxMap.LoadFromFile(const FileName: string);
var
  Document: IXMLDocument;
  Node: IXMLNode;
begin
  FFilePath := ExtractFilePath(FileName);
  Document := TXMLDocument.Create(nil);
  try
    Document.LoadFromFile(FileName);
    Node := Document.ChildNodes['map'];
    ParseMap(Node);
  finally
    Document := nil;
  end;
end;

procedure TTmxMap.ParseTileLayer(Node: IXMLNode);
var
  Name: string;
  Layer: TTmxTileLayer;
  ChildNode: IXMLNode;
begin
  Name := Node.Attributes['name'];
  Layer := TTmxTileLayer.Create(Name);
  Layer.Width := Node.Attributes['width'];
  Layer.Height := Node.Attributes['height'];
  FLayers.Add(Layer);

  if Node.HasAttribute('visible') then
    Layer.Visible := Node.Attributes['visible']
  else
    Layer.Visible := True;

  ChildNode := Node.ChildNodes.First;
  while Assigned(ChildNode) do
  begin
    if SameText(ChildNode.NodeName, 'data') then
      ParseTileLayerData(ChildNode, Layer);

    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TTmxMap.ParseTileLayerData(Node: IXMLNode; Layer: TTmxTileLayer);
var
  Encoding: string;
begin
  if Node.HasAttribute('encoding') then
  begin
    Encoding := Node.Attributes['encoding'];
    if SameText(Encoding, 'base64') then
      DecodeBinaryLayerData(Layer, Node.Text)
    else if SameText(Encoding, 'csv') then
      DecodeCSVLayerData(Layer, Node.Text);
  end;
end;

procedure TTmxMap.ParseMap(Node: IXMLNode);
var
  ChildNode: IXMLNode;
begin
  FWidth := Node.Attributes['width'];
  FHeight := Node.Attributes['height'];
  FTileWidth := Node.Attributes['tilewidth'];
  FTileHeight := Node.Attributes['tileheight'];

  ChildNode := Node.ChildNodes.First;
  while Assigned(ChildNode) do
  begin
    if SameText(ChildNode.NodeName, 'tileset') then
      ParseTileset(ChildNode)
    else if SameText(ChildNode.NodeName, 'layer') then
      ParseTileLayer(ChildNode)
    else if SameText(ChildNode.NodeName, 'objectgroup') then
      ParseObjectGroup(ChildNode);

    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TTmxMap.ParseObjectGroup(Node: IXMLNode);
var
  Name: string;
  ObjectGroup: TTmxObjectGroup;
  ChildNode: IXMLNode;
begin
  Name := Node.Attributes['name'];
  ObjectGroup := TTmxObjectGroup.Create(Name);
  FLayers.Add(ObjectGroup);

  if Node.HasAttribute('visible') then
    ObjectGroup.Visible := Node.Attributes['visible']
  else
    ObjectGroup.Visible := True;

  ChildNode := Node.ChildNodes.First;
  while Assigned(ChildNode) do
  begin
    if SameText(ChildNode.NodeName, 'object') then
      ParseObjectGroupObject(ChildNode, ObjectGroup);

    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TTmxMap.ParseObjectGroupObject(Node: IXMLNode;
  Group: TTmxObjectGroup);
var
  TmxObject: TTmxObject;
begin
  TmxObject := TTmxObject.Create;
  if Node.HasAttribute('id') then
    TmxObject.Id := Node.Attributes['id'];
  if Node.HasAttribute('name') then
    TmxObject.Name := Node.Attributes['name'];
  if Node.HasAttribute('type') then
    TmxObject.ObjectType := Node.Attributes['type'];
  if Node.HasAttribute('gid') then
    TmxObject.GId := Node.Attributes['gid'];
  TmxObject.X := Node.Attributes['x'];
  TmxObject.Y := Node.Attributes['y'];
  TmxObject.Width := Node.Attributes['width'];
  TmxObject.Height := Node.Attributes['height'];
  Group.Objects.Add(TmxObject);
end;

procedure TTmxMap.ParseTileset(Node: IXMLNode);
var
  Tileset: TTmxTileset;
  FirstGId: Integer;
  ChildNode: IXMLNode;
  Source: string;
begin
  FirstGId := Node.Attributes['firstgid'];
  if Node.HasAttribute('source') then
  begin
    Source := Node.Attributes['source'];

  end
  else
  begin
    Tileset := TTmxTileset.Create(FirstGId);
    Tileset.Name := Node.Attributes['name'];
    Tileset.TileWidth := Node.Attributes['tilewidth'];
    Tileset.TileHeight := Node.Attributes['tileheight'];
    Tileset.Columns := Node.Attributes['columns'];
    FTilesets.Add(FirstGId, Tileset);

    ChildNode := Node.ChildNodes.First;
    while Assigned(ChildNode) do
    begin
      if SameText(ChildNode.NodeName, 'tile') then
        ParseTilesetTile(ChildNode, Tileset)
      else if SameText(ChildNode.NodeName, 'image') then
        ParseTilesetImage(ChildNode, Tileset);

      ChildNode := ChildNode.NextSibling;
    end;
  end;
end;

procedure TTmxMap.ParseTilesetImage(Node: IXMLNode; Tileset: TTmxTileset);
var
  Source: string;
begin
  Source := Node.Attributes['source'];
  Tileset.Image.Source := TPath.Combine(FFilePath, Source);
  Tileset.Image.Width := Node.Attributes['width'];
  Tileset.Image.Height := Node.Attributes['height'];
  Tileset.LoadFromFile(Tileset.Image.Source);
end;

procedure TTmxMap.ParseTilesetTile(Node: IXMLNode; Tileset: TTmxTileset);
var
  Id: Integer;
  Tile: TTmxTile;
  ChildNode: IXMLNode;
begin
  Id := Node.Attributes['id'];
  Tile := TTmxTile.Create(Id, Tileset);
  Tileset.Tiles.Add(Id, Tile);

  ChildNode := Node.ChildNodes.First;
  while Assigned(ChildNode) do
  begin
    // if SameText(ChildNode.NodeName, 'image') then
    // ParseImage(ChildNode, Tileset);

    ChildNode := ChildNode.NextSibling;
  end;
end;

end.

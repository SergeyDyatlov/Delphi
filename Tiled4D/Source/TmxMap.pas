unit TmxMap;

interface

uses
  System.SysUtils, System.Classes, Xml.XMLIntf, XMLDoc, TmxLayer, TmxTileLayer,
  TmxTileset, TmxObjectGroup, System.Generics.Collections;

const
  FLIPPED_HORIZONTALLY_FLAG = $80000000;
  FLIPPED_VERTICALLY_FLAG = $40000000;
  FLIPPED_DIAGONALLY_FLAG = $20000000;

type
  TTmxMap = class
  private
    FFilePath: string;
    FOrientation: string;
    FWidth: Integer;
    FHeight: Integer;
    FTileWidth: Integer;
    FTileHeight: Integer;
    FTilesets: TObjectDictionary<Cardinal, TTmxTileset>;
    FLayers: TObjectList<TTmxLayer>;
    procedure ParseMap(Node: IXMLNode);
    procedure ParseTileset(Node: IXMLNode);
    procedure ParseTilesetTile(Node: IXMLNode; Tileset: TTmxTileset);
    procedure ParseTilesetTileImage(Node: IXMLNode; Tile: TTmxTile);
    procedure ParseTilesetImage(Node: IXMLNode; Tileset: TTmxTileset);
    procedure ParseTileLayer(Node: IXMLNode);
    procedure ParseTileLayerData(Node: IXMLNode; Layer: TTmxTileLayer);
    procedure DecodeBinaryLayerData(Layer: TTmxTileLayer; Text: string;
      DataFormat: TLayerDataFormat);
    procedure DecodeCSVLayerData(Layer: TTmxTileLayer; Text: string);
    function GetTilesetByGid(Gid: Cardinal): TTmxTileset;
    procedure ParseObjectGroup(Node: IXMLNode);
    procedure ParseObjectGroupObject(Node: IXMLNode; Group: TTmxObjectGroup);
    procedure ExtractFlipFlags(Gid: Cardinal; Cell: TTmxCell);
    function ClearFlipFlags(Gid: Cardinal): Cardinal;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const FileName: string);
    function FindLayerById(Id: Integer): TTmxLayer;
    function FindObjectById(Id: Integer): TTmxObject;
    property Orientation: string read FOrientation write FOrientation;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property TileWidth: Integer read FTileWidth;
    property TileHeight: Integer read FTileHeight;
    property Tilesets: TObjectDictionary<Cardinal, TTmxTileset> read FTilesets;
    property Layers: TObjectList<TTmxLayer> read FLayers;
  end;

  EDecompressionError = class(Exception);
  EEncodingError = class(Exception);

implementation

uses
  System.IOUtils, TmxImage, System.NetEncoding, System.ZLib, System.Variants;

{ TTmxMapReader }

resourcestring
  sCompressionMethodNotSupported = 'Compression method "%s" not supported';
  sUnknownEncoding = 'Unknown encoding: %s';

function TTmxMap.ClearFlipFlags(Gid: Cardinal): Cardinal;
begin
  Result := Gid and not(FLIPPED_HORIZONTALLY_FLAG or FLIPPED_VERTICALLY_FLAG or
    FLIPPED_DIAGONALLY_FLAG);
end;

constructor TTmxMap.Create;
begin
  FTilesets := TObjectDictionary<Cardinal, TTmxTileset>.Create([doOwnsValues]);
  FLayers := TObjectList<TTmxLayer>.Create(True);
end;

procedure TTmxMap.ExtractFlipFlags(Gid: Cardinal; Cell: TTmxCell);
begin
  Cell.FlippedDiagonaly := (Gid and FLIPPED_DIAGONALLY_FLAG) <> 0;
  Cell.FlippedHorizontaly := (Gid and FLIPPED_HORIZONTALLY_FLAG) <> 0;
  Cell.FlippedVerticaly := (Gid and FLIPPED_VERTICALLY_FLAG) <> 0;
end;

function TTmxMap.FindLayerById(Id: Integer): TTmxLayer;
var
  Layer: TTmxLayer;
begin
  Result := nil;
  for Layer in FLayers do
  begin
    if Layer.Id = Id then
      Exit(Layer);
  end;
end;

function TTmxMap.FindObjectById(Id: Integer): TTmxObject;
var
  Layer: TTmxLayer;
  Group: TTmxObjectGroup;
  TmxObject: TTmxObject;
begin
  Result := nil;
  for Layer in FLayers do
  begin
    if not (Layer.LayerType = ltObjectGroup) then
      Continue;

    Group := Layer as TTmxObjectGroup;
    for TmxObject in Group.Objects do
    begin
      if TmxObject.Id = Id then
        Exit(TmxObject);
    end;
  end;
end;

procedure TTmxMap.DecodeBinaryLayerData(Layer: TTmxTileLayer; Text: string;
  DataFormat: TLayerDataFormat);
var
  Bytes: TArray<Byte>;
  Input, Output: TStringStream;
  BinaryReader: TBinaryReader;
  X, Y: Integer;
  Gid, TileId: Cardinal;
  Tileset: TTmxTileset;
  Cell: TTmxCell;
begin
  Bytes := TNetEncoding.Base64.DecodeStringToBytes(Text);

  Input := TStringStream.Create(Bytes);
  Output := TStringStream.Create('');
  try
    if DataFormat = ldfBase64Zlib then
      ZDecompressStream(Input, Output)
    else
      Output.LoadFromStream(Input);

    Output.Position := 0;
    BinaryReader := TBinaryReader.Create(Output);
    try
      for Y := 0 to Layer.Height - 1 do
      begin
        for X := 0 to Layer.Width - 1 do
        begin
          Gid := BinaryReader.ReadUInt32;

          Cell := TTmxCell.Create;
          ExtractFlipFlags(Gid, Cell);
          Gid := ClearFlipFlags(Gid);
          Layer.SetCell(Cell, X, Y);

          if Gid <> 0 then
          begin
            Tileset := GetTilesetByGid(Gid);
            TileId := Gid - Tileset.FirstGId;
            Cell.SetTile(TileId, Tileset);
          end;
        end;
      end;
    finally
      BinaryReader.Free;
    end;
  finally
    Output.Free;
    Input.Free;
  end;
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

        Cell := TTmxCell.Create;
        ExtractFlipFlags(Gid, Cell);
        Gid := ClearFlipFlags(Gid);
        Layer.SetCell(Cell, X, Y);

        if Gid <> 0 then
        begin
          Tileset := GetTilesetByGid(Gid);
          TileId := Gid - Tileset.FirstGId;
          Cell.SetTile(TileId, Tileset);
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
  // NullStrictConvert := False;

  FTilesets.Clear;
  FLayers.Clear;

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
  Layer.Id := Node.Attributes['id'];
  Layer.Width := Node.Attributes['width'];
  Layer.Height := Node.Attributes['height'];
  FLayers.Add(Layer);

  if Node.HasAttribute('visible') then
    Layer.Visible := Node.Attributes['visible']
  else
    Layer.Visible := True;

  if Node.HasAttribute('opacity') then
    Layer.Opacity := Node.Attributes['opacity']
  else
    Layer.Opacity := 1;

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
  Compression: string;
  DataFormat: TLayerDataFormat;
begin
  Assert(Node.NodeName = 'data');
  if Node.HasAttribute('encoding') then
  begin
    Encoding := Node.Attributes['encoding'];
    if SameText(Encoding, 'csv') then
      DecodeCSVLayerData(Layer, Node.Text)
    else if SameText(Encoding, 'base64') then
    begin
      DataFormat := ldfBase64;
      if Node.HasAttribute('compression') then
      begin
        Compression := Node.Attributes['compression'];
        if SameText(Compression, 'zlib') then
          DataFormat := ldfBase64Zlib
        else
          raise EDecompressionError.CreateFmt(sCompressionMethodNotSupported,
            [Compression]);
      end;
      DecodeBinaryLayerData(Layer, Node.Text, DataFormat);
    end
    else
      raise EEncodingError.CreateFmt(sUnknownEncoding, [Encoding]);
  end;
end;

procedure TTmxMap.ParseMap(Node: IXMLNode);
var
  ChildNode: IXMLNode;
begin
  FOrientation := Node.Attributes['orientation'];
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
  ObjectGroup.Id := Node.Attributes['id'];
  FLayers.Add(ObjectGroup);
  
  if Node.HasAttribute('visible') then
    ObjectGroup.Visible := Node.Attributes['visible']
  else
    ObjectGroup.Visible := True;

  if Node.HasAttribute('opacity') then
    ObjectGroup.Opacity := Node.Attributes['opacity']
  else
    ObjectGroup.Opacity := 1;

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
  Id: Integer;
  TmxObject: TTmxObject;
  Gid, TileId: Cardinal;
  Tileset: TTmxTileset;
begin
  Id := Node.Attributes['id'];
  TmxObject := TTmxObject.Create(Id, Group);
  if Node.HasAttribute('name') then
    TmxObject.Name := Node.Attributes['name'];
  if Node.HasAttribute('type') then
    TmxObject.ObjectType := Node.Attributes['type'];
  if Node.HasAttribute('gid') then
  begin
    Gid := Node.Attributes['gid'];

    ExtractFlipFlags(Gid, TmxObject.Cell);
    TmxObject.Gid := ClearFlipFlags(Gid);

    if TmxObject.Gid <> 0 then
    begin
      Tileset := GetTilesetByGid(TmxObject.Gid);
      TileId := TmxObject.Gid - Tileset.FirstGId;
      TmxObject.Cell.SetTile(TileId, Tileset);
    end;
  end;
  TmxObject.X := Node.Attributes['x'];
  TmxObject.Y := Node.Attributes['y'];
  if Node.HasAttribute('width') then
    TmxObject.Width := Node.Attributes['width'];
  if Node.HasAttribute('height') then
    TmxObject.Height := Node.Attributes['height'];
  if Node.HasAttribute('rotation') then
    TmxObject.Rotation := Node.Attributes['rotation'];

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
    if Node.HasAttribute('columns') then
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
  if Tileset.Tiles.ContainsKey(Id) then
    Tile := Tileset.Tiles[Id]
  else
  begin
    Tile := TTmxTile.Create(Id, Tileset);
    Tileset.Tiles.Add(Id, Tile);
  end;

  ChildNode := Node.ChildNodes.First;
  while Assigned(ChildNode) do
  begin
    if SameText(ChildNode.NodeName, 'image') then
      ParseTilesetTileImage(ChildNode, Tile);

    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TTmxMap.ParseTilesetTileImage(Node: IXMLNode; Tile: TTmxTile);
var
  Source: string;
begin
  Source := Node.Attributes['source'];
  Tile.Source := TPath.Combine(FFilePath, Source);
  Tile.Width := Node.Attributes['width'];
  Tile.Height := Node.Attributes['height'];
  Tile.Bitmap.LoadFromFile(Tile.Source);
end;

end.

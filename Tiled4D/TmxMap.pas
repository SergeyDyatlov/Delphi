unit TmxMap;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections,
  TmxTileset, TmxTileLayer, TmxObjectGroup, Xml.XMLIntf, XMLDoc, Vcl.Graphics;

type
  TTmxMap = class
  private
    FFilePath: string;
    FWidth: Integer;
    FHeight: Integer;
    FTileWidth: Integer;
    FTileHeight: Integer;
    FTilesets: TObjectDictionary<Integer, TTmxTileset>;
    FTileLayers: TObjectList<TTmxTileLayer>;
    FObjectGroups: TObjectList<TTmxObjectGroup>;
    FBackgroundColor: TColor;
    procedure ParseXML(const Node: IXMLNode);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load(const FileName: string);
    function GetLayerByName(const Name: string): TTmxTileLayer;
    property FilePath: string read FFilePath write FFilePath;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property TileWidth: Integer read FTileWidth write FTileWidth;
    property TileHeight: Integer read FTileHeight write FTileHeight;
    property BackgroundColor: TColor read FBackgroundColor
      write FBackgroundColor;
    property Tilesets: TObjectDictionary<Integer, TTmxTileset> read FTilesets
      write FTilesets;
    property TileLayers: TObjectList<TTmxTileLayer> read FTileLayers
      write FTileLayers;
    property ObjectGroups: TObjectList<TTmxObjectGroup> read FObjectGroups
      write FObjectGroups;
  end;

implementation

uses
  Vcl.Dialogs, System.Types, Vcl.Imaging.pngimage, TmxUtils;

{ TMap }

constructor TTmxMap.Create;
begin
  FTilesets := TObjectDictionary<Integer, TTmxTileset>.Create([doOwnsValues]);
  FTileLayers := TObjectList<TTmxTileLayer>.Create(True);
  FObjectGroups := TObjectList<TTmxObjectGroup>.Create(True);
  FBackgroundColor := clBlack;
end;

destructor TTmxMap.Destroy;
begin
  FObjectGroups.Free;
  FTileLayers.Free;
  FTilesets.Free;
  inherited;
end;

function TTmxMap.GetLayerByName(const Name: string): TTmxTileLayer;
var
  Layer: TTmxTileLayer;
begin
  Result := nil;
  for Layer in TileLayers do
  begin
    if AnsiSameText(Layer.Name, Name) then
      Exit(Layer);
  end;
end;

procedure TTmxMap.Load(const FileName: string);
var
  Document: IXMLDocument;
  Node: IXMLNode;
begin
  FFilePath := ExtractFilePath(FileName);
  Document := TXMLDocument.Create(nil);
  try
    Document.LoadFromFile(FileName);
    Node := Document.ChildNodes['map'];
    ParseXML(Node);
  finally
    Document := nil;
  end;
end;

procedure TTmxMap.ParseXML(const Node: IXMLNode);
var
  ChildNode: IXMLNode;
  Tileset: TTmxTileset;
  Layer: TTmxTileLayer;
  ObjectGroup: TTmxObjectGroup;
  Value: string;
begin
  FWidth := Node.Attributes['width'];
  FHeight := Node.Attributes['height'];
  FTileWidth := Node.Attributes['tilewidth'];
  FTileHeight := Node.Attributes['tileheight'];

  if Node.HasAttribute('backgroundcolor') then
  begin
    Value := Node.Attributes['backgroundcolor'];
    FBackgroundColor := HtmlToColor(Value);
  end;

  ChildNode := Node.ChildNodes.First;
  while Assigned(ChildNode) do
  begin
    if SameText(ChildNode.NodeName, 'tileset') then
    begin
      Tileset := TTmxTileset.Create(FFilePath);
      Tileset.ParseXML(ChildNode);
      FTilesets.Add(Tileset.FirstGid, Tileset);
    end
    else if SameText(ChildNode.NodeName, 'layer') then
    begin
      Layer := TTmxTileLayer.Create;
      Layer.ParseXML(ChildNode);
      FTileLayers.Add(Layer);
    end
    else if SameText(ChildNode.NodeName, 'objectgroup') then
    begin
      ObjectGroup := TTmxObjectGroup.Create;
      ObjectGroup.ParseXML(ChildNode);
      FObjectGroups.Add(ObjectGroup);
    end;

    ChildNode := ChildNode.NextSibling;
  end;
end;

end.

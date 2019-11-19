unit TmxTileset;

interface

uses
  System.SysUtils, Vcl.Graphics, PngImage, System.Generics.Collections,
  Xml.XMLIntf;

type
  ETmxError = class(Exception);

  TTmxImage = class
  private
    FSource: string;
    FWidth: Integer;
    FHeight: Integer;
    FTmxPath: string;
  public
    constructor Create(const ATmxPath: string);
    destructor Destroy; override;
    procedure ParseXML(const Node: IXMLNode);
    property Source: string read FSource write FSource;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
  end;

  TTmxTile = class
  strict private
    FId: Integer;
    FImage: TTmxImage;
    FTmxPath: string;
  public
    constructor Create(const ATmxPath: string);
    destructor Destroy; override;
    procedure ParseXML(const Node: IXMLNode);
    property Id: Integer read FId write FId;
    property Image: TTmxImage read FImage write FImage;
  end;

  TTmxTileset = class
  strict private
    FFirstGid: Integer;
    FName: string;
    FTileWidth: Integer;
    FTileHeight: Integer;
    FTileCount: Integer;
    FColumns: Integer;
    FTiles: TObjectDictionary<Integer, TTmxTile>;
    FImage: TTmxImage;
    FTmxPath: string;
  public
    constructor Create(const ATmxPath: string);
    destructor Destroy; override;
    procedure ParseXML(const Node: IXMLNode);
    procedure LoadFromFile(const FileName: string);
    property FirstGid: Integer read FFirstGid write FFirstGid;
    property Name: string read FName write FName;
    property TileWidth: Integer read FTileWidth write FTileWidth;
    property TileHeight: Integer read FTileHeight write FTileHeight;
    property TileCount: Integer read FTileCount write FTileCount;
    property Columns: Integer read FColumns write FColumns;
    property Tiles: TObjectDictionary<Integer, TTmxTile> read FTiles
      write FTiles;
    property Image: TTmxImage read FImage write FImage;
  end;

implementation

uses
  Vcl.Dialogs, Xml.XMLDoc, System.IOUtils;

{ TTileset }

constructor TTmxTileset.Create(const ATmxPath: string);
begin
  FTmxPath := ATmxPath;
  FTiles := TObjectDictionary<Integer, TTmxTile>.Create([doOwnsValues]);
  FImage := TTmxImage.Create(FTmxPath);
end;

destructor TTmxTileset.Destroy;
begin
  FImage.Free;
  FTiles.Free;
  inherited;
end;

procedure TTmxTileset.LoadFromFile(const FileName: string);
var
  Document: IXMLDocument;
  Node: IXMLNode;
begin
  Document := TXMLDocument.Create(nil);
  try
    try
      Document.LoadFromFile(FileName);
      Node := Document.ChildNodes['tileset'];
      ParseXML(Node);
    except
      raise ETmxError.CreateFmt('Error loading: ', [FileName]);
    end;
  finally
    Document := nil;
  end;
end;

procedure TTmxTileset.ParseXML(const Node: IXMLNode);
var
  ChildNode: IXMLNode;
  Tile: TTmxTile;
  FileName: string;
begin
  if Node.HasAttribute('firstgid') then
    FFirstGid := Node.Attributes['firstgid'];

  if Node.HasAttribute('source') then
  begin
    FileName := Node.Attributes['source'];
    FileName := TPath.Combine(FTmxPath, FileName);
    LoadFromFile(FileName);
  end
  else
  begin
    FName := Node.Attributes['name'];
    FTileWidth := Node.Attributes['tilewidth'];
    FTileHeight := Node.Attributes['tileheight'];

    if Node.HasAttribute('tilecount') then
      FTileCount := Node.Attributes['tilecount'];
    if Node.HasAttribute('columns') then
      FColumns := Node.Attributes['columns'];

    ChildNode := Node.ChildNodes.First;
    while Assigned(ChildNode) do
    begin
      if SameText(ChildNode.NodeName, 'tile') then
      begin
        Tile := TTmxTile.Create(FTmxPath);
        Tile.ParseXML(ChildNode);
        FTiles.Add(Tile.Id, Tile);
      end
      else if SameText(ChildNode.NodeName, 'image') then
      begin
        FImage.ParseXML(ChildNode);
      end;

      ChildNode := ChildNode.NextSibling;
    end;
  end;
end;

{ TTmxTile }

constructor TTmxTile.Create(const ATmxPath: string);
begin
  FTmxPath := ATmxPath;
  FImage := TTmxImage.Create(FTmxPath);
end;

destructor TTmxTile.Destroy;
begin
  FImage.Free;
  inherited;
end;

procedure TTmxTile.ParseXML(const Node: IXMLNode);
var
  ChildNode: IXMLNode;
begin
  FId := Node.Attributes['id'];
  ChildNode := Node.ChildNodes['image'];
  FImage.ParseXML(ChildNode);
end;

{ TTmxImage }

constructor TTmxImage.Create(const ATmxPath: string);
begin
  inherited Create;
  FTmxPath := ATmxPath;
end;

destructor TTmxImage.Destroy;
begin

  inherited;
end;

procedure TTmxImage.ParseXML(const Node: IXMLNode);
begin
  FWidth := Node.Attributes['width'];
  FHeight := Node.Attributes['height'];
  FSource := Node.Attributes['source'];
  FSource := TPath.Combine(FTmxPath, FSource);
end;

end.

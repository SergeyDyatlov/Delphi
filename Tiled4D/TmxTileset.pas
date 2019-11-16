unit TmxTileset;

interface

uses
  Vcl.Graphics, PngImage, System.Generics.Collections, Xml.XMLIntf;

type
  TTmxImage = class
  private
    FSource: string;
    FWidth: Integer;
    FHeight: Integer;
  public
    procedure ParseXML(const Node: IXMLNode);
    property Source: string read FSource write FSource;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
  end;

  TTmxTile = class
  private
    FId: Integer;
    FImage: TTmxImage;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ParseXML(const Node: IXMLNode);
    property Id: Integer read FId write FId;
    property Image: TTmxImage read FImage write FImage;
  end;

  TTmxTileset = class
  private
    FFirstGid: Integer;
    FName: string;
    FTileWidth: Integer;
    FTileHeight: Integer;
    FTiles: TObjectDictionary<Integer, TTmxTile>;
    FImage: TTmxImage;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ParseXML(const Node: IXMLNode);
    property FirstGid: Integer read FFirstGid write FFirstGid;
    property Name: string read FName write FName;
    property TileWidth: Integer read FTileWidth write FTileWidth;
    property TileHeight: Integer read FTileHeight write FTileHeight;
    property Tiles: TObjectDictionary<Integer, TTmxTile> read FTiles
      write FTiles;
    property Image: TTmxImage read FImage write FImage;
  end;

implementation

uses
  System.SysUtils, Vcl.Dialogs;

{ TTileset }

constructor TTmxTileset.Create;
begin
  FTiles := TObjectDictionary<Integer, TTmxTile>.Create([doOwnsValues]);
  FImage := TTmxImage.Create;
end;

destructor TTmxTileset.Destroy;
begin
  FImage.Free;
  FTiles.Free;
  inherited;
end;

procedure TTmxTileset.ParseXML(const Node: IXMLNode);
var
  ChildNode: IXMLNode;
  Tile: TTmxTile;
begin
  FFirstGid := Node.Attributes['firstgid'];
  FName := Node.Attributes['name'];
  FTileWidth := Node.Attributes['tilewidth'];
  FTileHeight := Node.Attributes['tileheight'];

  ChildNode := Node.ChildNodes.First;
  while Assigned(ChildNode) do
  begin
    if SameText(ChildNode.NodeName, 'tile') then
    begin
      Tile := TTmxTile.Create;
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

{ TTmxTile }

constructor TTmxTile.Create;
begin
  FImage := TTmxImage.Create;
end;

destructor TTmxTile.Destroy;
begin
  FImage.Free;
  inherited;
end;

procedure TTmxTile.ParseXML(const Node: IXMLNode);
var
  ImageNode: IXMLNode;
begin
  FId := Node.Attributes['id'];
  ImageNode := Node.ChildNodes['image'];
  FImage.ParseXML(ImageNode);
end;

{ TTmxImage }

procedure TTmxImage.ParseXML(const Node: IXMLNode);
begin
  FWidth := Node.Attributes['width'];
  FHeight := Node.Attributes['height'];
  FSource := Node.Attributes['source'];
end;

end.

unit TmxObjectGroup;

interface

uses
  System.Generics.Collections, Xml.XMLIntf;

const
  FLIPPED_HORIZONTALLY_FLAG = $80000000;
  FLIPPED_VERTICALLY_FLAG = $40000000;
  FLIPPED_DIAGONALLY_FLAG = $20000000;

type
  TTmxObject = class
  private
    FId: Integer;
    FGid: Integer;
    FX: Double;
    FY: Double;
    FWidth: Double;
    FHeight: Double;
    FFlippedHorizontaly: Boolean;
    FFlippedVerticaly: Boolean;
    FFlippedDiagonaly: Boolean;
  public
    procedure ParseXML(const Node: IXMLNode);
    property Id: Integer read FId write FId;
    property Gid: Integer read FGid write FGid;
    property X: Double read FX write FX;
    property Y: Double read FY write FY;
    property Width: Double read FWidth write FWidth;
    property Height: Double read FHeight write FHeight;
    property FlippedHorizontaly: Boolean read FFlippedHorizontaly
      write FFlippedHorizontaly;
    property FlippedVerticaly: Boolean read FFlippedVerticaly
      write FFlippedVerticaly;
    property FlippedDiagonaly: Boolean read FFlippedDiagonaly
      write FFlippedDiagonaly;
  end;

  TTmxObjectGroup = class
  private
    FObjects: TObjectList<TTmxObject>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ParseXML(const Node: IXMLNode);
    property Objects: TObjectList<TTmxObject> read FObjects write FObjects;
  end;

implementation

uses
  System.SysUtils;

{ TTmxObjectGroup }

constructor TTmxObjectGroup.Create;
begin
  FObjects := TObjectList<TTmxObject>.Create(True);
end;

destructor TTmxObjectGroup.Destroy;
begin
  FObjects.Free;
  inherited;
end;

procedure TTmxObjectGroup.ParseXML(const Node: IXMLNode);
var
  ChildNode: IXMLNode;
  Obj: TTmxObject;
begin
  ChildNode := Node.ChildNodes.First;
  while Assigned(ChildNode) do
  begin
    Obj := TTmxObject.Create;
    Obj.ParseXML(ChildNode);
    FObjects.Add(Obj);

    ChildNode := ChildNode.NextSibling;
  end;
end;

{ TTmxObject }

procedure TTmxObject.ParseXML(const Node: IXMLNode);
var
  Value: string;
  RawGid: Int64;
  FS: TFormatSettings;
begin
  if Node.HasAttribute('id') then
    FId := Node.Attributes['id'];

  if Node.HasAttribute('gid') then
  begin
    Value := Node.Attributes['gid'];
    RawGid := StrToInt64(Value);

    FFlippedHorizontaly := (RawGid and FLIPPED_HORIZONTALLY_FLAG) <> 0;
    FFlippedVerticaly := (RawGid and FLIPPED_VERTICALLY_FLAG) <> 0;
    FFlippedDiagonaly := (RawGid and FLIPPED_DIAGONALLY_FLAG) <> 0;

    FGid := RawGid and not(FLIPPED_HORIZONTALLY_FLAG or
      FLIPPED_VERTICALLY_FLAG or FLIPPED_DIAGONALLY_FLAG);
  end;

  FS := TFormatSettings.Create;
  FS.DecimalSeparator := '.';
  Value := Node.Attributes['x'];
  FX := StrToFloat(Value, FS);
  Value := Node.Attributes['y'];
  FY := StrToFloat(Value, FS);
  Value := Node.Attributes['width'];
  FWidth := StrToFloat(Value, FS);
  Value := Node.Attributes['height'];
  FHeight := StrToFloat(Value, FS);
end;

end.

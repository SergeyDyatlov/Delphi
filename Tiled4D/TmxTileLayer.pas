unit TmxTileLayer;

interface

uses
  System.SysUtils, System.Classes, Xml.XMLIntf, TmxLayer;

type
  TTmxCSVData = array of array of Integer;

  TTmxTileLayer = class(TTmxLayer)
  private
    FWidth: Integer;
    FHeight: Integer;
    FData: TTmxCSVData;
  public
    procedure ParseXML(const Node: IXMLNode);
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property Data: TTmxCSVData read FData write FData;
  end;

implementation

{ TTmxLayer }

procedure TTmxTileLayer.ParseXML(const Node: IXMLNode);
var
  ChildNode: IXMLNode;
  List: TStringList;
  TokenList: TStringList;
  X, Y: Integer;
  Gid: string;
begin
  Name := Node.Attributes['name'];
  FWidth := Node.Attributes['width'];
  FHeight := Node.Attributes['height'];

  Visible := True;
  if Node.HasAttribute('visible') then
    Visible := Node.Attributes['visible'];

  ChildNode := Node.ChildNodes['data'];
  SetLength(FData, FHeight, FWidth);

  List := TStringList.Create;
  TokenList := TStringList.Create;
  try
    List.Text := ChildNode.Text;
    List.Delete(0);

    TokenList.Delimiter := ',';
    TokenList.StrictDelimiter := True;
    for Y := 0 to FHeight - 1 do
    begin
      TokenList.DelimitedText := List[Y];
      for X := 0 to FWidth - 1 do
      begin
        Gid := TokenList[X];
        FData[Y, X] := StrToInt(Gid);
      end;
    end;
  finally
    TokenList.Free;
    List.Free;
  end;
end;

end.

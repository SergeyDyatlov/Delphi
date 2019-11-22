unit TmxTileLayer;

interface

uses
  System.SysUtils, System.Classes, Xml.XMLIntf, TmxLayer, System.NetEncoding,
  System.ZLib;

type
  TTmxLayerData = array of array of Integer;

  TTmxTileLayer = class(TTmxLayer)
  private
    FWidth: Integer;
    FHeight: Integer;
    FData: TTmxLayerData;
    FEncoding: string;
    FCompression: string;
    function DecodeBase64(const Text: string): string;
    procedure ParseLayerData(const Text: string);
    procedure ParseCSVData(const Text: string);
    procedure ParseBase64Data(const Text: string);
  public
    procedure ParseXML(const Node: IXMLNode);
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property Data: TTmxLayerData read FData write FData;
    property Encoding: string read FEncoding write FEncoding;
    property Compression: string read FCompression write FCompression;
  end;

implementation

uses
  TmxTypes;

{ TTmxLayer }

function TTmxTileLayer.DecodeBase64(const Text: string): string;
var
  Bytes: TArray<Byte>;
begin
  Bytes := TNetEncoding.Base64.DecodeStringToBytes(Text);
  Result := TEncoding.ANSI.GetString(Bytes);
end;

procedure TTmxTileLayer.ParseBase64Data(const Text: string);
var
  DecodedText: string;
  Input, Output: TStringStream;
  Binary: TBinaryReader;
  X, Y: Integer;
begin
  DecodedText := DecodeBase64(Text);
  Input := TStringStream.Create(DecodedText, TEncoding.ANSI);
  Output := TStringStream.Create('');
  try
    if AnsiSameText(FCompression, 'zlib') then
      ZDecompressStream(Input, Output)
    else
      Output.LoadFromStream(Input);

    Output.Position := 0;
    Binary := TBinaryReader.Create(Output);
    try
      for Y := 0 to FHeight - 1 do
      begin
        for X := 0 to FWidth - 1 do
          FData[Y, X] := Binary.ReadUInt32;
      end;
    finally
      Binary.Free;
    end;
  finally
    Output.Free;
    Input.Free;
  end;
end;

procedure TTmxTileLayer.ParseCSVData(const Text: string);
var
  List, TokenList: TStringList;
  X, Y: Integer;
begin
  List := TStringList.Create;
  TokenList := TStringList.Create;
  try
    List.Text := Text;
    List.Delete(0);

    TokenList.Delimiter := ',';
    TokenList.StrictDelimiter := True;
    for Y := 0 to FHeight - 1 do
    begin
      TokenList.DelimitedText := List[Y];
      for X := 0 to FWidth - 1 do
        FData[Y, X] := TokenList[X].ToInteger;
    end;
  finally
    TokenList.Free;
    List.Free;
  end;
end;

procedure TTmxTileLayer.ParseLayerData(const Text: string);
begin
  SetLength(FData, FHeight, FWidth);
  if SameText(FEncoding, 'base64') then
  begin
    try
      ParseBase64Data(Text);
    except
      raise ETmxError.Create('Error parsing base64 data');
    end;
  end
  else if SameText(FEncoding, 'csv') then
  begin
    try
      ParseCSVData(Text);
    except
      raise ETmxError.Create('Error parsing csv data');
    end;
  end;
end;

procedure TTmxTileLayer.ParseXML(const Node: IXMLNode);
var
  ChildNode: IXMLNode;
begin
  Name := Node.Attributes['name'];
  FWidth := Node.Attributes['width'];
  FHeight := Node.Attributes['height'];

  Visible := True;
  if Node.HasAttribute('visible') then
    Visible := Node.Attributes['visible'];

  ChildNode := Node.ChildNodes['data'];
  if ChildNode.HasAttribute('encoding') then
    FEncoding := ChildNode.Attributes['encoding'];
  if ChildNode.HasAttribute('compression') then
    FCompression := ChildNode.Attributes['compression'];

  ParseLayerData(ChildNode.Text);
end;

end.

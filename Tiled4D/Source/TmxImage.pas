unit TmxImage;

interface

type
  TTmxImage = class
  private
    FWidth: Integer;
    FHeight: Integer;
    FSource: string;
  public
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property Source: string read FSource write FSource;
  end;

implementation

end.

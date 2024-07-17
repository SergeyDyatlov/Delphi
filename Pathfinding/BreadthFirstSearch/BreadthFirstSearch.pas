unit BreadthFirstSearch;

interface

uses
  System.Types, System.Generics.Collections;

type
  TBreadthFirstSearch<T> = class
  private
    FVisited: TDictionary<T, T>;
    function BuildPath(StartNode, EndNode: T): TArray<T>;
    function GetNeighbors(Node: T): TArray<T>; virtual; abstract;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Search(StartNode, EndNode: T): TArray<T>;
    property Visited: TDictionary<T, T> read FVisited write FVisited;
  end;

implementation

{ TBreadthFirstSearch }

function TBreadthFirstSearch<T>.BuildPath(StartNode, EndNode: T)
  : TArray<T>;
var
  Path: TList<T>;
  Current: T;
begin
  Path := TList<T>.Create;
  try
    Current := EndNode;
    while Current <> StartNode do
    begin
      Path.Insert(0, Current);
      Current := FVisited[Current];
    end;
  finally
    Path.Free;
  end;
end;

constructor TBreadthFirstSearch<T>.Create;
begin
  FVisited := TDictionary<T, T>.Create;
end;

destructor TBreadthFirstSearch<T>.Destroy;
begin
  FVisited.Free;
  inherited;
end;

function TBreadthFirstSearch<T>.Search(StartNode, EndNode: T)
  : TArray<T>;
var
  Queue: TQueue<T>;
  Current, Next: T;
  Neighbors: TArray<T>;
begin
  FVisited.Clear;
  Queue := TQueue<T>.Create;
  try
    Queue.Enqueue(StartNode);
    FVisited.Add(StartNode, Default(T));

    while Queue.Count > 0 do
    begin
      Current := Queue.Dequeue;
      if Current = EndNode then
        Break;

      Neighbors := GetNeighbors(Current);
      for Next in Neighbors do
      begin
        if not FVisited.ContainsKey(Next) then
        begin
          Queue.Enqueue(Next);
          FVisited.Add(Next, Current);
        end;
      end;
    end;

    Result := BuildPath(StartNode, EndNode);
  finally
    Queue.Free;
  end;
end;

end.

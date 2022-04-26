program flag;

uses
   Crt, Dos;

const
   spd = 1;
   size = 3;
   curve = 125;
   xmax = 250 div size;
   ymax = 150 div size;
   sofs = 30;
   samp = 10;
   slen = 255;

type
   screenbuffertype = array[0..63999] of Byte;
   screenbufferptr = ^screenbuffertype;

var
   buffer: screenbufferptr;
   screen_y: array[0..199] of Word;
   stab: array[0..slen] of Word;

procedure calcscreeny(width: Word);
var
   i: Integer;
begin
   for i := 0 to 199 do
          screen_y[i] := i * width;
end;

procedure init_graph;
var
   regs: Registers;
begin
   regs.ah := $00;
   regs.al := $13;
   Intr($10, regs);
   buffer := Ptr($a000, 0);
   calcscreeny(320);
end;

procedure close_graph;
var
   regs: Registers;
begin
   regs.ah := $00;
   regs.al := $03;
   Intr($10, regs);
end;

procedure csin;
var
   i: Byte;
begin
   for i := 0 to slen do
            stab[i] := Round(Sin(i * 4 *pi/slen) * samp) + sofs;
end;

procedure display_flag;
type
   scrarray = array[0..xmax, 0..ymax] of Byte;
var
   postab: array[0..xmax, 0..ymax] of Word;
   bitmap: scrarray;
   x, y, xp, yp, sidx: Word;
begin
   sidx := 0;
   for x := 0 to xmax do
          for y := 0 to (ymax div 3) do
                bitmap[x, y] := lightblue;
          for x := 0 to xmax do
                for y := (ymax div 3) to 2 * (ymax div 3) do
                bitmap[x, y] := yellow;
          for x := 0 to xmax do
                for y := 2 * (ymax div 3) to ymax do
                bitmap[x, y] := black;
          for x := 0 to xmax do
                for y := 0 to ymax do
                         postab[x, y] := 0;
          repeat
                for x := 0 to xmax do
                      for y := ymax downto 0 do
                      begin
                          buffer^[postab[x, y]] := 0;
                          xp := size * x + stab[(sidx + curve * (x + y)) mod slen];
                          yp := size * y + stab[(sidx + 4 * x + (curve + 1) * y) mod slen];
                          postab[x, y] := xp + screen_y[yp];
                          buffer^[postab[x, y]] := bitmap[x, y];
                      end;
                sidx := (sidx + spd) mod slen;
          until KeyPressed;
   end;

   begin
      csin;
      init_graph;
      display_flag;
      close_graph;
   end.
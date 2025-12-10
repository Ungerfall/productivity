using System;
using System.Runtime.InteropServices;
using System.Threading.Tasks;

if (Args.Count == 0)
{
    Console.WriteLine("Usage: dotnet script main.csx <delay> [stopTime]");
    return;
}

TimeSpan ts;
if (!TimeSpan.TryParse(Args[0], out ts))
{
    ts = TimeSpan.FromMilliseconds(int.Parse(Args[0]));
}

var stopTime = Args.Count >= 2 ? DateTime.Parse(Args[1]) : (DateTime?)null;
var mousePos = new[] { (200, 200), (300, 200), (200, 300), (300, 300) };
int i = 0;
while (true)
{
    MouseOperations.SetCursorPosition(mousePos[i].Item1, mousePos[i].Item2);
    MouseOperations.MouseEvent(MouseOperations.MouseEventFlags.LeftDown | MouseOperations.MouseEventFlags.LeftUp);
    Console.WriteLine($"{mousePos[i]}-{Guid.NewGuid()}-{(stopTime - DateTime.Now)?.TotalSeconds ?? 0}");
    i++;
    if (i == 4)
        i = 0;

    await Task.Delay(ts);

    if (stopTime.HasValue && DateTime.Now >= stopTime.Value)
        break;
}

public class MouseOperations
{
    [Flags]
    public enum MouseEventFlags
    {
        LeftDown = 0x00000002,
        LeftUp = 0x00000004,
        MiddleDown = 0x00000020,
        MiddleUp = 0x00000040,
        Move = 0x00000001,
        Absolute = 0x00008000,
        RightDown = 0x00000008,
        RightUp = 0x00000010
    }

    [DllImport("user32.dll", EntryPoint = "SetCursorPos")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool SetCursorPos(int x, int y);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool GetCursorPos(out MousePoint lpMousePoint);

    [DllImport("user32.dll")]
    private static extern void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);

    public static void SetCursorPosition(int x, int y)
    {
        SetCursorPos(x, y);
    }

    public static void SetCursorPosition(MousePoint point)
    {
        SetCursorPos(point.X, point.Y);
    }

    public static MousePoint GetCursorPosition()
    {
        MousePoint currentMousePoint;
        var gotPoint = GetCursorPos(out currentMousePoint);
        if (!gotPoint) { currentMousePoint = new MousePoint(0, 0); }
        return currentMousePoint;
    }

    public static void MouseEvent(MouseEventFlags value)
    {
        MousePoint position = GetCursorPosition();

        mouse_event
            ((int)value,
                position.X,
                position.Y,
                0,
                0)
            ;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct MousePoint
    {
        public int X;
        public int Y;

        public MousePoint(int x, int y)
        {
            X = x;
            Y = y;
        }
    }
}

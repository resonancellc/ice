module app;

import std.stdio;
import std.conv;
import std.string;

import ice;

PeerSelf self;

void main()
{
    writeln("ice client.");

    self = new PeerSelf(false);    // when false: Each run is assigned a new peerId
    self.autoConnectPeerOthers = true;

    self.start(
        (string fromPeerId, ubyte[] data, bool isForward)
        {
            onReceive(fromPeerId, data, isForward);
        }
    );

    showMenu();

    string line;
    while ((line = readln()) !is null)
    {
        line = line[0..$ - 1];        
        if (line == string.init)
        {
            write("Please input: ");
            continue;
        }

        if (line == "exit")
        {
            self.savePeers();
            writeln("bye.\n");
            import core.stdc.stdlib;
            exit(0);
            return;
        }

        if (line == "menu")
        {
            showMenu();
            continue;
        }

        writeln("Please input: ");
        self.broadcastMessage(cast(ubyte[])line);
    }
}

void showMenu()
{
    writeln();    
    if (!trackerConnected) writeln("Not connection to tracker(server).");

    writeln("All peers:");
    for(int i; i < peers.keys.length; i++)
    {
        PeerOther po = peers[peers.keys[i]];
        writefln("%d: %s: %s:%d\t%s\t[%s]%s", i + 1, peers.keys[i], po.natInfo.externalIp, po.natInfo.externalPort, po.natInfo.natType, po.hasHole ? "Connected" : "Not conn", (peers.keys[i] == self.peerId) ? "[self]" : "");
    }
    writeln("Menu:");
    writeln("1. press the \"menu\" to show this menu items.");
    writeln("2. press a string will be send to all peers.");
    writeln("3. press \"exit\" to exit the client.");
    writeln("Please input: ");
}

void onReceive(string fromPeerId, ubyte[] data, bool isForward)
{
    writefln("%s%s: %s", fromPeerId, isForward ? "[Forward]" : "", cast(string)data);
    writeln("Please input: ");
}

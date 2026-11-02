// Pure byte-cap tests only; never invoke inventory Main, OS APIs or PowerShell.
using System;
using System.Text;
class ConsoleInventoryBufferTests {
    static int Main() {
        try {
            int checks=0;
            foreach(string text in new[]{"short failure",new string('x',30000),new string('\u4e2d',30000),new string('\u00e9',30000),String.Concat(System.Linq.Enumerable.Repeat("\U0001f642",10000)),new string('\ud800',30000)}) {
                byte[] data=ConsoleImageInventory.FailureBytes(text);
                if(data.Length>16384)throw new Exception("UTF8 failure byte cap exceeded");
                new UTF8Encoding(false,true).GetString(data);checks+=2;
            }
            Console.WriteLine(checks+" pure failure UTF8 cap/validity assertions passed; no inventory or native APIs invoked.");return 0;
        }catch(Exception e){Console.WriteLine(e.ToString());return 1;}
    }
}

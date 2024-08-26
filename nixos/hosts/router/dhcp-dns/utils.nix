{lib, ...}: let
  padLeft = len: char: str: let
    diff = len - builtins.stringLength str;
  in
    builtins.concatStringsSep "" (builtins.concatLists [(builtins.genList (_: char) diff ++ [str])]);
  expandIpv6 = address: let
    parts = lib.strings.splitString ":" address;
    zeroesNeeded = 8 - (builtins.length parts);
    expandedParts = builtins.concatLists (map (x:
      if x == ""
      then builtins.genList (_: "0000") zeroesNeeded
      else [(padLeft 4 "0" x)])
    parts);
  in
    expandedParts;
in {
  subnet4ToReverseDomain = subnet4: let
    octets = lib.strings.splitString "." (builtins.elemAt (lib.strings.splitString "/" subnet4) 0);
    prefixLength = lib.strings.toInt (builtins.elemAt (lib.strings.splitString "/" subnet4) 1);
    relevantOctets = lib.lists.take (prefixLength / 8) octets; # will only work for prefixes divisible by 8
    reversedOctets = lib.lists.reverseList relevantOctets;
  in "${lib.strings.concatStringsSep "." reversedOctets}.in-addr.arpa.";

  subnet6ToReverseDomain = subnet6: let
    parts = lib.strings.splitString "/" subnet6;
    address = builtins.elemAt parts 0;
    prefixLength = lib.strings.toInt (builtins.elemAt parts 1);
    expandedAddress = expandIpv6 address;
    allHexDigits = lib.strings.stringToCharacters (builtins.concatStringsSep "" expandedAddress);
    nibblesToUse = prefixLength / 4;
    relevantNibbles = lib.lists.take nibblesToUse allHexDigits;
    reversedNibbles = lib.lists.reverseList relevantNibbles;
  in "${(builtins.concatStringsSep "." reversedNibbles)}.ip6.arpa.";
}

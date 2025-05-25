{
  flip,
  pipe,
  splitString,
  head,
  listToAttrs,
  nameValuePair,
  getAttrFromPath,
  ...
}: {
  genFunctionArgs = flip pipe [(map (flip pipe [(splitString ".") head (flip nameValuePair false)])) listToAttrs];
  genInputsWith = pkgs: map (flip pipe [(splitString ".") (flip getAttrFromPath pkgs)]);
}

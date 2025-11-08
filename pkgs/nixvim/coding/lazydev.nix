{...}: {
  youthlic.plugins = {
    lazydev = {
      enable = true;
      settings = {
        library = [
          {
            path = "$''{3rd}/luv/library";
            words = ["vim%.uv"];
          }
        ];
      };
    };
  };
}

@get_url =() ->
  return url_prefix_smart()

@url_prefix_smart =() ->
  path = location.pathname;
  path = path.split('/');
  url = [location.origin, path[1], path[2]].join('/')
  return url

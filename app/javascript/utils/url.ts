export const getSearchParam = (name: string): string | null => {
  const searchParams = window.location.search.substr(1);
  const split = searchParams.split('&');
  return split.find(param => param.startsWith(name))?.substr(name.length + 1);
};

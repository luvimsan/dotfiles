local M = {}

function M.prefer_local(local_path, remote_src)
  local expanded = vim.fs.normalize(vim.fn.expand(local_path))
  if vim.uv.fs_stat(expanded) then
    return expanded
  end
  return remote_src
end

return M

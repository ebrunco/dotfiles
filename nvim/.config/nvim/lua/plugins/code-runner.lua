return {
  "CRAG666/code_runner.nvim", -- Corrected username and repo name
  config = function()
    require("code_runner").setup({
      filetype = {
        c = "cd $dir && gcc *.c -o $fileNameWithoutExt && $dir/$fileNameWithoutExt",
      },
    })
  end,
}

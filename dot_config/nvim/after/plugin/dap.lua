require('dap-go').setup {
   dap_configurations = {
    {
      -- Must be "go" or it will be ignored by the plugin
      type = "go",
      name = "Attach remote",
      mode = "remote",
      request = "attach",
    },
  },
  delve = {
    initialize_timeout_sec = 20,
    port = "${port}"
  },
}

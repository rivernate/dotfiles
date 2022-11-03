vim.filetype.add({
  extension = {
    -- avsc (AVRO schema) files are really just JSON
    avsc = 'json'
  }
})

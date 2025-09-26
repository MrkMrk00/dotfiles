vim.bo.errorformat = table.concat({
    '%E%f(%l\\,%c): error %m',
    '%W%f(%l\\,%c): warning %m',
    '%E%f(%l\\,%c): %m',
    '%Z%\\s%\\+%m',
}, ',')

" https://eggjs.org/zh-cn/advanced/loader.html#loadtocontext
if !exists('g:eggjs_gf_loadpath')
  let g:eggjs_gf_loadpath = 'service\|proxy'
endif

function! GetPlusCmd(methodName)
  let plus_cmd_func = '\\(^\\|\\s\\)' . a:methodName . '\\s*('
  let plus_cmd_exports = '\\<exports\\.' . a:methodName . '\\s*='
  let plus_cmd = '+/\\(' . plus_cmd_func . '\\)\\|\\(' . plus_cmd_exports . '\\)/'
  " let plus_cmd = '+/\\<' . a:methodName . '\\s*(/ '
  return plus_cmd
endfunction

function! ReplaceProxyPath(fname)
  " Replace root alias name like '@/mode-name' to '<ROOT>/mode-name'
  let filename = substitute(a:fname, '^@\/', '', '')

  " TODO:
  " 如果文件不存在，还需要将驼峰替换成下划线，
  " 如果有多个驼峰，甚至需要各种组合形式的尝试。Eggjs 真坑。
  "
  " ctx.proxy:
  " - this.ctx.proxy.${facadeName}.${methodName}
  " + app/proxy/${facadeName}.js
  "
  " ctx.service:
  " - this.ctx.service.${filePathName}.${methodName}
  " + app/service/${facadeName}.js
  let re_eggjs = '\(\(this\.\)\?ctx\.\|this\.\)\?\('. g:eggjs_gf_loadpath .'\)\.\([a-zA-Z0-9_\$\.]\+\)\.\([a-zA-Z0-9_\$]\+\)$'

  if matchstr(filename, re_eggjs) != ''
    let filePath = substitute(filename, re_eggjs, '\3/\4', '')
    let filePath = substitute(filePath, '\.', '/', 'g')

    let methodName = substitute(filename, re_eggjs, '\5', '')
    let b:jsgf_plus_cmd = GetPlusCmd(methodName)

    return filePath
  endif

  " Enum:
  " - com.alipay.${appName}.common.service.facade.enums.${EnumName}
  " + app/proxy-enums/alipay-${appName}-common/${EnumName}.js

  " TODO: 如果 controllers 文件夹不存在，还需要替换为 controller 试试。
  " app.controller -> app/controller
  let re_controller = '\(\(this\.\)\?app\.\)\?\(controllers\?\)\.\([a-zA-Z0-9\._]\+\)\.\(\w\+\)$'
  if matchstr(filename, re_controller) != ''
    let filePath = substitute(filename, re_controller, 'controllers/\4', '')
    let filePath = substitute(filePath, '\.', '/', 'g')

    let methodName = substitute(filename, re_controller, '\5', '')
    let b:jsgf_plus_cmd = GetPlusCmd(methodName)

    return filePath
  endif

  return filename
endfunction

" Egg/Chair 的 controllers, proxy, service 定义文件跳转
function! InitEggProxyGF()
  let proxyClass = finddir('app/proxy-class', expand('%:p:h') . ';')
  execute 'setlocal path+=' . proxyClass . '/*/*'
  let appPath = finddir('app', expand('%:p:h') . ';')
  execute 'setlocal path+=' . appPath
  set includeexpr=ReplaceProxyPath(v:fname)
endfunction

auto FileType javascript,typescript call InitEggProxyGF()

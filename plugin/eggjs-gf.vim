" https://eggjs.org/zh-cn/advanced/loader.html#loadtocontext
if !exists('g:eggjs_gf_loadpath')
  let g:eggjs_gf_loadpath = 'service\|proxy'
endif

function! ReplaceProxyPath(fname)
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
  if matchstr(a:fname, re_eggjs) != ''
    let filePath = substitute(a:fname, re_eggjs, '\3/\4', '')
    let filePath = substitute(filePath, '\.', '/', 'g')

    let methodName = substitute(a:fname, re_eggjs, '\5', '')
    let b:jsgf_plus_cmd = '+/\\(^\\|\\s\\)' . methodName . '\\s*(/'
    " let b:jsgf_plus_cmd = '+/\\<' . methodName . '\\s*(/ '

    return filePath
  endif

  " Enum:
  " - com.alipay.${appName}.common.service.facade.enums.${EnumName}
  " + app/proxy-enums/alipay-${appName}-common/${EnumName}.js

  " TODO: 如果 controllers 文件夹不存在，还需要替换为 controller 试试。
  " app.controller -> app/controller
  let re_controller = '\(\(this\.\)\?app\.\)\?\(controllers\?\)\.\([a-zA-Z0-9\._]\+\)\.\(\w\+\)$'
  if matchstr(a:fname, re_controller) != ''
    let filePath = substitute(a:fname, re_controller, 'controllers/\4', '')
    let filePath = substitute(filePath, '\.', '/', 'g')

    let methodName = substitute(a:fname, re_controller, '\5', '')
    let b:jsgf_plus_cmd = '+/\\(^\\|\\s\\)' . methodName . '\\s*(/'
    " let b:jsgf_plus_cmd = '+/\\<' . methodName . '\s*(/ '

    return filePath
  endif

  return a:fname
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

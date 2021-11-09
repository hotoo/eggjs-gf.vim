
function! ReplaceProxyPath(fname)
  " TODO:
  " 如果 controller 不存在，还需要替换为 controllers 试试。
  " app.controller
  let filePath = substitute(a:fname, '\(\(this\.\)\?app\.\)\?\(controllers\?\)\.\([a-zA-Z0-9\._]\+\)\.\w\+$', 'controllers/\4', '')

  " https://eggjs.org/zh-cn/advanced/loader.html#loadtocontext
  if !exists('g:eggjs_gf_loadpath')
    let g:eggjs_gf_loadpath = 'service\|proxy'
  endif

  " TODO:
  " 如果文件不存在，还需要将驼峰替换成下划线，
  " 如果有多个驼峰，甚至需要各种组合形式的尝试。Egg 真坑。
  " ctx.service, ctx.proxy
  let filePath = substitute(filePath, '\(\(this\.\)\?ctx\.\)\?\('. g:eggjs_gf_loadpath .')\.\([a-zA-Z0-9_\$\.]\+\)\.[a-zA-Z0-9_\$]\+$', '\3/\4', '')
  let filePath = substitute(filePath, '\.', '/', 'g')
  return filePath
endfunction

" Egg/Chair 的 proxy 跳转
function! InitEggProxyGF()
  let proxyClass = finddir('app/proxy-class', expand('%:p:h') . ';')
  execute 'setlocal path+=' . proxyClass . '/*/*'

  " TODO: 对于 Enum 需要特殊处理：
  " - com.alipay.${appName}.common.service.facade.enums.${EnumName}
  " + app/proxy-enums/alipay-${appName}-common/${EnumName}.js
  " let proxyEnums = finddir('app/proxy-enums', expand('%:p:h') . ';')
  " execute 'setlocal path+=' . proxyEnums . '/*'

  " 对于 proxy 需要特殊处理：
  " - this.ctx.proxy.${facadeName}.${methodName}
  " + app/proxy/${facadeName}.js
  " let proxy = finddir('app/proxy', expand('%:p:h') . ';')
  " execute 'setlocal path+=' . proxy
  " " 给 includeexpr 用的 substitute 中的正则模式，反斜杠需要多转义一次。
  " set includeexpr=substitute(v:fname,'\\(this\\.\\)\\?\\(ctx\\.\\)\\?proxy\\.\\(\\w\\+\\)\\.\\w\\+$','\\3','')

  " 对于 app/controller, app.service, app.proxy 特殊处理：
  " - this.ctx.service.${filePathName}.${methodName}
  " + app/service/${facadeName}.js
  let appPath = finddir('app', expand('%:p:h') . ';')
  execute 'setlocal path+=' . appPath
  " 给 includeexpr 用的 substitute 中的正则模式，反斜杠需要多转义一次。
  " set includeexpr=substitute(v:fname,'\\(this\\.\\)\\?\\(ctx\\.\\)\\?\\(controller\\\|service\\\|proxy\\)\\.\\(\\[\\w\\.\\]\\+\\)\\.\\w\\+$','\\3/\\4','')
  set includeexpr=ReplaceProxyPath(v:fname)
endfunction

auto FileType javascript,typescript call InitEggProxyGF()

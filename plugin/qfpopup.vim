" vim:foldmethod=marker:fen:
scriptencoding utf-8

if exists('g:loaded_qfpopup') && g:loaded_qfpopup
  finish
endif
let g:loaded_qfpopup = 1

if !has('patch-8.1.1462')
  echohl ErrorMsg
  echomsg 'qfpopup: this plugin requires Vim 8.1.1462'
  echohl None
  finish
endif

let s:save_cpo = &cpo
set cpo&vim


function! s:popup_error_under_cursor() abort
  popupclear
  let error = s:get_error_by_pos(getpos('.'), win_getid())
  " Skip if current line is same as `error.text`
  " because it's useless (no additional information).
  " e.g.) the quickfix of `:grep`
  if empty(error) || error.text ==# getline('.')
    return
  endif
  call s:popup_error(error)
endfunction

function! s:popup_error(error) abort
  call popup_create(a:error.text, {
  \ 'moved': 'any',
  \ 'line': 'cursor',
  \ 'col': 'cursor',
  \})
endfunction

" TODO use {what} argument
" TODO filter by more accurate pos
function! s:get_error_by_pos(pos, winid) abort
  let [bufnr, lnum] = a:pos[0:1]
  let loclist = getloclist(a:winid)
  let qflist = getqflist()
  let l:F = { _,error -> error.bufnr is bufnr && error.lnum is lnum }
  call filter(loclist, l:F)
  call filter(qflist, l:F)
  return !empty(loclist) ? loclist[0] :
  \      !empty(qflist)  ? qflist[0]  : {}
endfunction


augroup qfpopup
  autocmd!
  autocmd CursorMoved * call s:popup_error_under_cursor()
augroup END


let &cpo = s:save_cpo

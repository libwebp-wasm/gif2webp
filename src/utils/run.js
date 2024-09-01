import { parseGif2WebpArgs } from './parse-command-args'

export function runGif2Webp(module, main, ...args) {
  module[main || '_main'](...parseGif2WebpArgs(module, args))
}

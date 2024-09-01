import { GIF2WEBP_DEFAULT_ARGS } from '../config'

// https://github.com/ffmpegwasm/ffmpeg.wasm/blob/master/src/utils/parseArgs.js
function parseCommandArgs(module, args) {
  const argsPtr = module._malloc(args.length * Uint32Array.BYTES_PER_ELEMENT)

  args.forEach((s, idx) => {
    const [sz = module.lengthBytesUTF8(s) + 1, buf = module._malloc(sz)] = []

    module.stringToUTF8(s, buf, sz)
    module.setValue(argsPtr + Uint32Array.BYTES_PER_ELEMENT * idx, buf, 'i32')
  })

  return [args.length, argsPtr]
}

export function parseGif2WebpArgs(gif2webp, args) {
  return parseCommandArgs(gif2webp, GIF2WEBP_DEFAULT_ARGS.concat(args))
}

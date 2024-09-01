import pkg from './package.json'

export const EXTERNALS = [pkg.dependencies, pkg.peerDependencies]
  .map((dependencies) => Object.keys(dependencies || {}))
  .flat(1)
  .map((name) => RegExp(`^${name}($|/)`))

export const GLOBAL_NAME = 'Gif2webp'

export const LIBRARY_NAME = 'gif2webp'

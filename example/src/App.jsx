import { useRef, useState, useCallback } from 'react'
import { Input, Radio, Button } from 'antd'
import {
  initFS,
  Gif2Webp,
  runGif2Webp,
  initLocateFile,
  getFileWithBlobData,
  writeFileWithUint8ArrayData
} from '@libwebp-wasm/gif2webp'
import gif2webp from '@libwebp-wasm/gif2webp/lib/gif2webp.wasm?url'

export default function App() {
  const fileRef = useRef(null)
  const [type, setType] = useState()
  const [url, setUrl] = useState('')

  const handleTransform = useCallback(() => {
    Gif2Webp({
      ...initLocateFile(gif2webp)
    }).then((instance) => {
      const fileReader = new FileReader()

      fileReader.onerror = () => reject()
      fileReader.onload = ({ target: { result: elements } }) => {
        const [
          { name: sourceName } = fileRef.current,
          targetName = sourceName.replace(/\.gif$/, '.webp')
        ] = []

        initFS(instance, '/gif2webp')
        writeFileWithUint8ArrayData(instance, sourceName, elements)
        runGif2Webp(
          instance,
          '_main',
          ...(type ? [type] : []),
          '-q',
          '75',
          sourceName,
          '-o',
          targetName
        )
        setUrl(URL.createObjectURL(getFileWithBlobData(instance, targetName)))
      }

      fileReader.readAsArrayBuffer(fileRef.current)
    })
  }, [type])
  const handleFileChange = useCallback(({ target: { files } }) => {
    ;({ 0: fileRef.current } = files)
  }, [])
  const handleTypeChange = useCallback(({ target: { value } }) => {
    setType(value)
  }, [])

  return (
    <div className='App'>
      <div style={{ display: 'flex', alignItems: 'center' }}>
        <Input
          type='file'
          bordered={false}
          style={{ width: 200 }}
          onChange={handleFileChange}
        />
        <Radio.Group value={type} onChange={handleTypeChange}>
          <Radio value='-lossy'>lossy</Radio>
          <Radio value='-mixed'>mixed</Radio>
        </Radio.Group>
        <Button type='primary' onClick={handleTransform}>
          Transform
        </Button>
      </div>
      <output
        hidden={!url}
        style={{ width: 412, paddingLeft: 11, paddingTop: 7 }}
      >
        <img src={url} style={{ width: '100%' }} />
      </output>
    </div>
  )
}

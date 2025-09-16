import { Application } from 'oak'
import { contract } from './contract.ts'
import { log } from './log.ts'

const port = 3000

const app = new Application()
app.use(contract.routes())

log.info({ msg: `listening on port: ${port}` })
await app.listen({ port })

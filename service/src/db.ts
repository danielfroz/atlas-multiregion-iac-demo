import { MongoClient } from "mongodb"
import { log } from "./log.ts"

const url = Deno.env.get('MONGODB_URL') ?? 'mongodb://localhost:27017'

log.info({ msg: `connecting to cluster`, url })

const client = new MongoClient(url, {
  writeConcern: {
    w: 'majority',
    journal: true
  },
  readPreference: 'nearest'
})

const db = client.db('account')
const coll = db.collection('contracts')
export { coll }

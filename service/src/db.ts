import { MongoClient } from "mongodb"
import { log } from "./log.ts"

const url = Deno.env.get('MONGODB_URL') ?? 'mongodb://localhost:27017'

log.info({ msg: `connecting to cluster`, url })

const client = new MongoClient(url, {
  writeConcern: {
    w: 'majority',
    journal: true
  },
  readPreference: 'nearest',
  serverSelectionTimeoutMS: 3000,
  socketTimeoutMS: 45000,
  minPoolSize: 5,
  maxPoolSize: 100,
  maxIdleTimeMS: 30000,
  waitQueueTimeoutMS: 2500,
})

const db = client.db('account')
const coll = db.collection('contracts')
export { coll }

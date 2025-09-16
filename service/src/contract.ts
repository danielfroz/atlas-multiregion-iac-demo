import { faker } from 'faker';
import { Context, Router } from 'oak';
import { coll } from "./db.ts";
import { log } from "./log.ts";

const contract = new Router()

interface SendArgs {
  ctx: Context,
  status: number,
  body?: unknown
}

const send = (args: SendArgs): void => {
  const { ctx, status, body } = args
  ctx.response.status = status
  ctx.response.type = 'application/json'
  ctx.response.body = body ?? {}
}

/**
 * Delete
 */
contract.delete('/contract/:tid/:id', async (ctx) => {
  const { tid, id } = ctx.params
  if(!tid || !id) {
    log.error({ msg: 'bad request tid or id missing' })
    return send({ ctx, status: 404, body: { error: 'tid required' }})
  }
  await coll.deleteOne({ tid, id })
  return send({ ctx, status: 200, body: { success: true }})
})

/**
 * Get
 */
contract.get('/contract/:tid/:id', async (ctx) => {
  const { tid, id } = ctx.params
  if(!tid || !id) {
    log.error({ msg: 'bad request tid or id missing' })
    return send({ ctx, status: 404, body: { error: 'tid required' }})
  }
  const doc = await coll.findOne({ tid, id })
  if(!doc) {
    log.info({ msg: 'no contract found'})
    return send({ 
      ctx,
      status: 404,
      body: { error: 'contract not found' }
    })
  }
  log.info({ msg: 'returning contract', contract: doc })
  return send({ ctx, status: 200, body: doc })
})

/**
 * List
 */
contract.get('/contract/:tid', async (ctx) => {
  const{ tid } = ctx.params
  if(!tid) {
    log.error({ msg: 'bad request; tid missing' })
    return send({ ctx, status: 400, body: { error: 'tid required' }})
  }
  const cur = coll.find({ tid }).limit(50).sort({ _id: 1 })
  try {
    const contracts = await cur.toArray() || []
    return send({ ctx, status: 200, body: contracts })
  }
  finally {
    cur.close()
  }
})

/**
 * Save
 */
contract.post('/contract/:tid', async (ctx) => {
  const { tid } = ctx.params
  if(!tid) {
    log.error({ msg: 'bad request; tid missing' })
    return send({ ctx, status: 400, body: { error: 'tid required' }})
  }
  const body = await ctx.request.body.json()
  if(!body) {
    log.error({ msg: 'bad request; body missing' })
    return send({ ctx, status: 400, body: { error: 'badrequest'}})
  }

  const doc = body
  // contract must have the fields:
  // created: Date
  // tid: tenant id
  // year: year
  // active: boolean

  doc.tid = tid
  const date = faker.date.past({ years: 2 })
  if(!doc.created) {
    doc.created = new Date(date)
  }
  if(!doc.year) {
    doc.year = ''+date.getFullYear()
  }
  if(doc.active == null) {
    doc.active = false
  }

  log.info({ msg: 'replacing contract', id: doc.id, contract: doc })
  await coll.replaceOne({ tid: doc.tid, id: doc.id }, doc, { upsert: true })
  return send({ ctx, status: 200, body: doc })
})

export { contract };

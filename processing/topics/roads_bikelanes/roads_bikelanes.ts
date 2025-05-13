import { sql } from 'bun'

type R = { id: string, osm_id: string, tags: any }

export async function run() {
  console.log(`TODO: HELLO FROM DYNAMICALLY LOADED TS`)
  const tablesToPrint = ['roads', 'bikelanes']
  for await (const table of tablesToPrint) {
    const [[count]] = await sql`
      SELECT count(id) FROM roads
    `.values()
    console.log(`\nTable ${table} has ${count} rows.. printing first 100`)
    const rows : R[] = await sql`SELECT id, osm_id, tags FROM ${sql(table)} LIMIT 100`
    for (const [idx, { id, osm_id, tags }] of rows.entries()) {
      console.log(`  ${table} row ${idx}: ${id}, ${osm_id}, ${tags.name}`)
    }
  }
}

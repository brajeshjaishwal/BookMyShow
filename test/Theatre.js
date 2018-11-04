var Theatre = artifacts.require('Theatre')
const assert = require('chai').assert
const truffleAssert = require('truffle-assertions')
/*
1. Four (4) ticketing windows sell movie tickets at a theatre
2. People can buy one or more tickets
3. Once 100 tickets are sold for a movie, that movie-show  is full
4. The theatre runs 5 movies at any time, and each show 4 times a day
5. Once a ticket is purchased a buyer automatically gets a bottle of water and popcorn on Window-1
6. At the end of the purchase, a ticket and receipt  is printed and the purchase is recorded on the blockchain
7. The buyer can go and exchange the water for soda at the cafeteria. Window 1 must generate a random number. If that number is even, the buyer must be able to get the water exchanged for soda at the cafeteria. The cafeteria has only 200 sodas, so only the first 200 requesters can exchange. 

Exercise 1: Write a go program that simulates this - make assumptions and clearly document assumptions.
*/
contract('Theatre', async(accounts) => {
  let _theatre

  beforeEach('Setup a theatre', async () => {
    _theatre = await Theatre.new('First Theatre', 'First location')
  }),
  it('Check theatre name', async() => {
    assert.equal(await _theatre.theatre_name(), 'First Theatre', 'Should be First Theatre')
  }),
  it('Check theatre location', async() => {
    assert.equal(await _theatre.theatre_location(), 'First location', 'Should be First location')
  }),
  it('Check add movie', async() => {
    let tx
    tx = await _theatre.addMovie('First Movie')
    truffleAssert.eventEmitted(tx, 'MovieEvent')
    tx = await _theatre.addMovie('Second Movie')
    truffleAssert.eventEmitted(tx, 'MovieEvent')
    tx = await _theatre.addMovie('Third Movie')
    truffleAssert.eventEmitted(tx, 'MovieEvent')
    tx = await _theatre.addMovie('Fourth Movie')
    truffleAssert.eventEmitted(tx, 'MovieEvent')
    tx = await _theatre.addMovie('Fifth Movie')
    truffleAssert.eventEmitted(tx, 'MovieEvent')
    await truffleAssert.reverts(_theatre.addMovie('Sixth Movie'))
  }),
  it('Check create new show', async() => {
    await _theatre.createNewShow()
  }),
  it('Check book ticket successful', async() => {
    let result = await _theatre.bookTicket("First Movie","2","2","brajesh jaishwal","9413844898","3")
    truffleAssert.eventEmitted(result, 'TicketEvent', 
                              args => args.eventType === 'booked',
                              'TicketEvent should be emitted with booked result')
    let ticket = await _theatre.getTicket(0)
    assert.equal(ticket.customer, "brajesh jaishwal", "Customer should be brajesh jaishwal")
  }),
  it('Check claim surprise', async() => {
    let tx
    tx = await _theatre.claimSurprise(1, 0)
    truffleAssert.eventEmitted(tx, 'SurpriseEvent',
                              args => args.eventType === 'claimed',
                              'SurpriseEvent should be emitted with claimed result')
  }),
  it('Check exchange soda', async() => {
    let tx
    tx = await _theatre.exchangeSurprise(0)
    truffleAssert.eventEmitted(tx, 'SurpriseEvent', 
                              args => args.eventType === 'claimed',
                              'SurpriseEvent should be emitted with claimed result')
  })
});

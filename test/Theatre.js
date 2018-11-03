var Theatre = artifacts.require('Theatre')
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
    let result
    result = await _theatre.addMovie('First Movie')
    console.log(result)
    assert.isTrue( result, 'Should be First Movie')

    result = await _theatre.addMovie('Second Movie')
    assert.isTrue( result, 'Should be First Movie')

    result = await _theatre.addMovie('Third Movie')
    assert.isTrue( result, 'Should be First Movie')

    result = await _theatre.addMovie('Fourth Movie')
    assert.equal( result, 'Fourth Movie', 'Should be First Movie')

    result = await _theatre.addMovie('Fifth Movie')
    assert.equal( result, 'Fifth Movie', 'Should be First Movie')

    result = await _theatre.addMovie('Sixth Movie')
    assert.equal( result, 'We cannot add more movie', 'Should not add more movie')
  })
});

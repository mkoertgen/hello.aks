const supertest = require('supertest');
const app = require('../app');

describe('Routes', () => {
  let request = null
  let server = null

  before(function (done) {
    server = app.listen(done)
    request = supertest.agent(server)
  })

  after(function (done) {
    server.close(done)
  })

  describe('GET /', () => {
    it('should return 200', done => {
      request
        .get('/')
        .expect(200, done);
    });
  });
  describe('GET /messages', () => {
    it('should return 200', done => {
      request
        .get('/messages')
        .expect('Content-Type', /json/)
        .expect(200, done);
    });
  });
  describe('GET /messages/notfound', () => {
    it('should return 404', done => {
      request
        .get('/messages/notfound')
        .expect(404, done);
    });
  });
});

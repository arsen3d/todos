{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Factory } = require 'meteor/factory'
{ Todos } = require '../todos/todos.coffee'


class ListsCollection extends Mongo.Collection
  insert: (list, callback) ->
    unless list.name?
      nextLetter = 'A'
      list.name = "List #{nextLetter}"

      while this.findOne({name: list.name})?
        # not going to be too smart here, can go past Z
        nextLetter = String.fromCharCode(nextLetter.charCodeAt(0) + 1)
        list.name = "List #{nextLetter}"

    super.insert list, callback

  remove: (selector, callback) ->
    Todos.remove {listId: selector}
    super.remove selector, callback

Lists = exports.Lists = new ListsCollection 'Lists'


# Deny all client-side updates since we will be using methods to manage this collection
Lists.deny
  insert: ->
    yes

  update: ->
    yes

  remove: ->
    yes


Lists.schema = new SimpleSchema
  name:
    type: String
  incompleteCount:
    type: Number
    defaultValue: 0
  userId:
    type: String
    regEx: SimpleSchema.RegEx.Id
    optional: yes

Lists.attachSchema Lists.schema

# This represents the keys from Lists objects that should be published
# to the client. If we add secret properties to List objects, don't list
# them here to keep them private to the server.
Lists.publicFields =
  name: 1
  incompleteCount: 1
  userId: 1

Factory.define 'list', Lists, {}


Lists.helpers
  isPrivate: ->
    @userId?


  isLastPublicList: ->
    publicListCount = Lists.find(userId: $exists: yes).count()
    not @isPrivate() and publicListCount is 1


  editableBy: (userId) ->
    unless @userId?
      return yes

    @userId is userId


  todos: ->
    Todos.find { listId: @_id }, sort: createdAt: -1
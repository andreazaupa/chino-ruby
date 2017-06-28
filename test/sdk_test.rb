require "test/unit"
require_relative "../lib/chino_ruby"

class SDKTest < Test::Unit::TestCase
   
   def setup
       @RAILS_ROOT = File.join(File.dirname(__FILE__), '../')
       @KEYS = YAML::load(File.open("#{@RAILS_ROOT}/config-chino.yml"))
       
       #    @DEVELOPMENT_KEYS = @KEYS['development_old']
       @DEVELOPMENT_KEYS = @KEYS['development']
       
       @client = ChinoAPI.new(@DEVELOPMENT_KEYS['customer_id'], @DEVELOPMENT_KEYS['customer_key'], @DEVELOPMENT_KEYS['url'])
       @success = "success"
   end
   
   def test_applications
       description = "test_application_ruby"
       description_updated = "test_application_ruby_updated"
       app = @client.applications.create_application(description, "password", "")
       assert_equal(app.app_name, description)
       assert_not_equal(app.app_id, "")
       app = @client.applications.get_application(app.app_id)
       assert_equal(app.app_name, description)
       assert_not_equal(app.app_id, "")
       app = @client.applications.update_application(app.app_id, description_updated, "password", "")
       assert_equal(app.app_name, description_updated)
       assert_not_equal(app.app_id, "")
       apps = @client.applications.list_applications()
       apps.applications.each do |a|
           assert_not_equal(app.app_id, "")
           assert_not_equal(app.app_name, "")
       end
       apps = @client.applications.list_applications_with_params(2, 2)
       apps.applications.each do |a|
           assert_not_equal(app.app_id, "")
       end
       assert_equal(@client.applications.delete_application(app.app_id, true), @success)
   end
   
   def test_repositories
       description = "test_repository_ruby"
       description_updated = "test_repository_ruby_updated"
       repo = @client.repositories.create_repository(description)
       assert_equal(repo.description, description)
       assert_not_equal(repo.repository_id, "")
       
       repo = @client.repositories.update_repository(repo.repository_id, description_updated)
       assert_equal(repo.description, description_updated)
       assert_not_equal(repo.repository_id, "")
       
       repos = @client.repositories.list_repositories()
       repos.repositories.each do |r|
           assert_not_equal(r.repository_id, "")
       end
       assert_equal(@client.repositories.delete_repository(repo.repository_id, true), @success)
   end
   
   def test_schemas
       description = "test_repository_ruby"
       repo = @client.repositories.create_repository(description)
       assert_equal(repo.description, description)
       assert_not_equal(repo.repository_id, "")
       
       fields = []
       fields.push(Field.new("string", "test_string", true))
       fields.push(Field.new("integer", "test_integer", true))
       fields.push(Field.new("blob", "test_blob", false))
       
       description = "test-schema-description-ruby"
       
       schema = @client.schemas.create_schema(repo.repository_id, description, fields)
       assert_equal(schema.description, description)
       assert_equal(schema.getFields.size, 3)
       assert_not_equal(schema.schema_id, description)
       
       schema = @client.schemas.get_schema(schema.schema_id)
       assert_equal(schema.description, description)
       assert_equal(schema.getFields.size, 3)
       assert_not_equal(schema.schema_id, description)
       
       
       description = "test-schema-description-ruby-updated"
       
       schema = @client.schemas.update_schema(schema.schema_id, description, fields)
       assert_equal(schema.description, description)
       assert_equal(schema.getFields.size, 3)
       assert_not_equal(schema.schema_id, description)
       
       schemas = @client.schemas.list_schemas(repo.repository_id)
       schemas.schemas.each do |s|
           assert_equal(s.description, description)
           assert_not_equal(s.schema_id, description)
       end
       assert_equal(@client.schemas.delete_schema(schema.schema_id, true), @success)
       assert_equal(@client.repositories.delete_repository(repo.repository_id, true), @success)
   end
   
   def test_documents
       description = "test_repository_ruby"
       repo = @client.repositories.create_repository(description)
       assert_equal(repo.description, description)
       assert_not_equal(repo.repository_id, "")
       
       fields = []
       fields.push(Field.new("string", "test_string", true))
       fields.push(Field.new("integer", "test_integer", true))
       fields.push(Field.new("blob", "test_blob", false))
       
       description = "test-schema-description-ruby"
       
       schema = @client.schemas.create_schema(repo.repository_id, description, fields)
       assert_equal(schema.description, description)
       assert_equal(schema.getFields.size, 3)
       assert_not_equal(schema.schema_id, description)
       
       content = Hash.new
       content["test_string"] = "sample value ruby"
       content["test_integer"] = 123
       
       doc = @client.documents.create_document(schema.schema_id, content)
       assert_not_equal(doc.document_id, "")
       
       doc = @client.documents.get_document(doc.document_id)
       assert_equal(doc.content['test_string'], "sample value ruby")
       assert_equal(doc.content['test_integer'], 123)
       assert_not_equal(doc.document_id, "")
       
       content["test_integer"] = 1233
       
       doc = @client.documents.update_document(doc.document_id, content)
       assert_not_equal(doc.document_id, "")
       
       doc = @client.documents.get_document(doc.document_id)
       assert_equal(doc.content['test_string'], "sample value ruby")
       assert_equal(doc.content['test_integer'], 1233)
       assert_not_equal(doc.document_id, "")
       
       docs = @client.documents.list_documents(schema.schema_id, true)
       docs.documents.each do |d|
           assert_not_equal(d.document_id, "")
       end
       
       docs = @client.documents.list_documents_with_params(schema.schema_id, false, 100, 0)
       docs.documents.each do |d|
           assert_not_equal(d.document_id, "")
       end
       
       assert_equal(@client.documents.delete_document(doc.document_id, true), @success)
       assert_equal(@client.schemas.delete_schema(schema.schema_id, true), @success)
       assert_equal(@client.repositories.delete_repository(repo.repository_id, true), @success)
   end
   
   def test_user_schemas
       description = "test-user-schema-description-ruby"
       description_updated = "test-user-schema-description-ruby-updated"
       fields = []
       fields.push(Field.new("string", "test_string", true))
       fields.push(Field.new("integer", "test_integer", true))
       
       u_schema = @client.user_schemas.create_user_schema(description, fields)
       assert_equal(u_schema.description, description)
       assert_equal(u_schema.getFields.size, 2)
       assert_not_equal(u_schema.user_schema_id, "")
       
       u_schema = @client.user_schemas.get_user_schema(u_schema.user_schema_id)
       assert_equal(u_schema.description, description)
       assert_equal(u_schema.getFields.size, 2)
       assert_not_equal(u_schema.user_schema_id, "")
       
       u_schema = @client.user_schemas.update_user_schema(u_schema.user_schema_id, description_updated, fields)
       assert_equal(u_schema.description, description_updated)
       assert_equal(u_schema.getFields.size, 2)
       assert_not_equal(u_schema.user_schema_id, "")
       
       schemas = @client.user_schemas.list_user_schemas()
       schemas.user_schemas.each do |s|
           assert_not_equal(s.user_schema_id, "")
       end
       assert_equal(@client.user_schemas.delete_user_schema(u_schema.user_schema_id, true), @success)
   end
   
   def test_users
       description = "test-user-schema-description-ruby"
       fields = []
       fields.push(Field.new("string", "test_string", true))
       fields.push(Field.new("integer", "test_integer", true))
       
       u_schema = @client.user_schemas.create_user_schema(description, fields)
       assert_equal(u_schema.description, description)
       assert_equal(u_schema.getFields.size, 2)
       assert_not_equal(u_schema.user_schema_id, "")
       
       attributes = Hash.new
       attributes["test_string"] = "sample value ruby"
       attributes["test_integer"] = 123
       
       username = "testUsernameRuby"+rand(1..300).to_s
       
       usr = @client.users.create_user(u_schema.user_schema_id, username, "testPassword", attributes)
       assert_equal(usr.user_attributes['test_string'], "sample value ruby")
       assert_equal(usr.user_attributes['test_integer'], 123)
       assert_not_equal(usr.user_id, "")
       
       usr = @client.users.get_user(usr.user_id)
       assert_equal(usr.user_attributes['test_string'], "sample value ruby")
       assert_equal(usr.user_attributes['test_integer'], 123)
       assert_not_equal(usr.user_id, "")
       
       attributes["test_integer"] = 1233
       
       usr = @client.users.update_user(usr.user_id, username, "testPassword", attributes)
       assert_equal(usr.user_attributes['test_string'], "sample value ruby")
       assert_equal(usr.user_attributes['test_integer'], 1233)
       assert_not_equal(usr.user_id, "")
       
       attributes = Hash.new
       attributes["test_integer"] = 666
       
       usr = @client.users.update_user_partial(usr.user_id, attributes)
       assert_equal(usr.user_attributes['test_string'], "sample value ruby")
       assert_equal(usr.user_attributes['test_integer'], 666)
       assert_not_equal(usr.user_id, "")
       
       users = @client.users.list_users(u_schema.user_schema_id)
       users.users.each do |u|
           assert_not_equal(u.user_id, "")
       end
       assert_equal(@client.users.delete_user(usr.user_id, true), @success)
       assert_equal(@client.user_schemas.delete_user_schema(u_schema.user_schema_id, true), @success)
   end
   
   def test_groups
       description = "test-user-schema-description-ruby"
       fields = []
       fields.push(Field.new("string", "test_string", true))
       fields.push(Field.new("integer", "test_integer", true))
       
       u_schema = @client.user_schemas.create_user_schema(description, fields)
       assert_equal(u_schema.description, description)
       assert_equal(u_schema.getFields.size, 2)
       assert_not_equal(u_schema.user_schema_id, "")
       
       attributes = Hash.new
       attributes["test_string"] = "sample value ruby"
       attributes["test_integer"] = 123
       
       username = "testUsernameRuby"+rand(1..300).to_s
       
       usr = @client.users.create_user(u_schema.user_schema_id, username, "testPassword", attributes)
       assert_equal(usr.user_attributes['test_string'], "sample value ruby")
       assert_equal(usr.user_attributes['test_integer'], 123)
       assert_not_equal(usr.user_id, "")
       
       group_name = "testGroup"+rand(1..300).to_s
       
       group = @client.groups.create_group(group_name, attributes)
       assert_equal(group.group_attributes['test_string'], "sample value ruby")
       assert_equal(group.group_attributes['test_integer'], 123)
       assert_not_equal(group.group_id, "")
       
       group = @client.groups.get_group(group.group_id)
       assert_equal(group.group_attributes['test_string'], "sample value ruby")
       assert_equal(group.group_attributes['test_integer'], 123)
       assert_not_equal(group.group_id, "")
       
       attributes["test_string"] = "sample value ruby"
       attributes["test_integer"] = 1233
       
       group = @client.groups.update_group(group.group_id, group_name, attributes)
       assert_equal(group.group_attributes['test_string'], "sample value ruby")
       assert_equal(group.group_attributes['test_integer'], 1233)
       assert_not_equal(group.group_id, "")
       
       groups = @client.groups.list_groups_with_params(100, 0)
       groups.groups.each do |g|
           assert_not_equal(g.group_id, "")
       end
       
       assert_equal(@client.groups.add_user_to_group(usr.user_id, group.group_id), @success)
       assert_equal(@client.groups.add_user_schema_to_group(u_schema.user_schema_id, group.group_id), @success)
       
       usr = @client.users.get_user(usr.user_id)
       assert_not_equal(usr.user_id, "")
       assert_equal(usr.groups.size, 1)
       
       assert_equal(@client.groups.remove_user_from_group(usr.user_id, group.group_id), @success)
       assert_equal(@client.groups.remove_user_schema_from_group(u_schema.user_schema_id, group.group_id), @success)
       
       usr = @client.users.get_user(usr.user_id)
       assert_not_equal(usr.user_id, "")
       assert_equal(usr.groups.size, 0)
       
       assert_equal(@client.groups.delete_group(group.group_id, true), @success)
       assert_equal(@client.users.delete_user(usr.user_id, true), @success)
       assert_equal(@client.user_schemas.delete_user_schema(u_schema.user_schema_id, true), @success)
   end
   
   def test_collections
       description = "test_repository_ruby"
       repo = @client.repositories.create_repository(description)
       assert_equal(repo.description, description)
       assert_not_equal(repo.repository_id, "")
       
       fields = []
       fields.push(Field.new("string", "test_string", true))
       fields.push(Field.new("integer", "test_integer", true))
       fields.push(Field.new("blob", "test_blob", false))
       
       description = "test-schema-description-ruby"
       
       schema = @client.schemas.create_schema(repo.repository_id, description, fields)
       assert_equal(schema.description, description)
       assert_equal(schema.getFields.size, 3)
       assert_not_equal(schema.schema_id, description)
       
       content = Hash.new
       content["test_string"] = "sample value ruby"
       content["test_integer"] = 123
       
       doc = @client.documents.create_document(schema.schema_id, content)
       assert_not_equal(doc.document_id, "")
       
       description = "test-decription-ruby"+rand(1..300).to_s
       
       col = @client.collections.create_collection(description)
       assert_not_equal(col.collection_id, "")
       assert_equal(col.name, description)
       
       col = @client.collections.update_collection(col.collection_id, description+"-updated")
       assert_not_equal(col.collection_id, "")
       assert_equal(col.name, description+"-updated")
       
       cols = @client.collections.list_collections()
       cols.collections.each do |c|
           assert_not_equal(c.collection_id, "")
       end
       
       assert_equal(@client.collections.add_document(doc.document_id, col.collection_id), @success)
       
       docs = @client.collections.list_documents(col.collection_id)
       assert_equal(docs.documents.size, 1)
       docs.documents.each do |d|
           assert_not_equal(d.document_id, "")
       end
       
       assert_equal(@client.collections.remove_document(doc.document_id, col.collection_id), @success)
       
       docs = @client.collections.list_documents(col.collection_id)
       assert_equal(docs.documents.size, 0)
       
       assert_equal(@client.collections.delete_collection(col.collection_id, true), @success)
       assert_equal(@client.documents.delete_document(doc.document_id, true), @success)
       assert_equal(@client.schemas.delete_schema(schema.schema_id, true), @success)
       assert_equal(@client.repositories.delete_repository(repo.repository_id, true), @success)
   end
   
   def test_permissions
       description = "test_repository_ruby"
       repo = @client.repositories.create_repository(description)
       assert_equal(repo.description, description)
       assert_not_equal(repo.repository_id, "")
       
       fields = []
       fields.push(Field.new("string", "test_string", true))
       fields.push(Field.new("integer", "test_integer", true))
       fields.push(Field.new("blob", "test_blob", false))
       
       description = "test-schema-description-ruby"
       
       schema = @client.schemas.create_schema(repo.repository_id, description, fields)
       assert_equal(schema.description, description)
       assert_equal(schema.getFields.size, 3)
       assert_not_equal(schema.schema_id, description)
       
       content = Hash.new
       content["test_string"] = "sample value ruby"
       content["test_integer"] = 123
       
       doc = @client.documents.create_document(schema.schema_id, content)
       assert_not_equal(doc.document_id, "")
       
       description = "test-user-schema-description-ruby"
       fields = []
       fields.push(Field.new("string", "test_string", true))
       fields.push(Field.new("integer", "test_integer", true))
       
       u_schema = @client.user_schemas.create_user_schema(description, fields)
       assert_equal(u_schema.description, description)
       assert_equal(u_schema.getFields.size, 2)
       assert_not_equal(u_schema.user_schema_id, "")
       
       attributes = Hash.new
       attributes["test_string"] = "sample value ruby"
       attributes["test_integer"] = 123
       
       username = "testUsernameRuby"+rand(1..300).to_s
       
       usr = @client.users.create_user(u_schema.user_schema_id, username, "testPassword", attributes)
       assert_equal(usr.user_attributes['test_string'], "sample value ruby")
       assert_equal(usr.user_attributes['test_integer'], 123)
       assert_not_equal(usr.user_id, "")
       
       assert_equal(@client.permissions.permissions_on_resources("grant", "repositories", "users", usr.user_id, ["R", "U"], ["R"]), @success)
       
       perms = @client.permissions.read_permissions_of_a_user(usr.user_id)
       assert_equal(perms.permissions.size, 1)
       perms.permissions.each do |p|
           assert_equal(p.permission['Manage'], ["R", "U"])
       end
       
       assert_equal(@client.permissions.permissions_on_a_resource_children_created_document("grant", "schemas", schema.schema_id, "documents", "users", usr.user_id, ["R", "U", "C"], [], ["R", "U", "D"], ["R"]), @success)
       
       perms = @client.permissions.read_permissions_of_a_user(usr.user_id)
       assert_equal(perms.permissions.size, 2)
       perms.permissions.each do |p|
           if not p.permission['created_document']==nil
               assert_equal(p.permission['created_document']['Manage'], ["R", "U", "D"])
           end
       end
       assert_equal(@client.users.delete_user(usr.user_id, true), @success)
       assert_equal(@client.user_schemas.delete_user_schema(u_schema.user_schema_id, true), @success)
       assert_equal(@client.documents.delete_document(doc.document_id, true), @success)
       assert_equal(@client.schemas.delete_schema(schema.schema_id, true), @success)
       assert_equal(@client.repositories.delete_repository(repo.repository_id, true), @success)
   end
   
   def test_search
       description = "test_repository_ruby"
       repo = @client.repositories.create_repository(description)
       assert_equal(repo.description, description)
       assert_not_equal(repo.repository_id, "")
       
       fields = []
       fields.push(Field.new("string", "test_string", true))
       fields.push(Field.new("integer", "test_integer", true))
       fields.push(Field.new("blob", "test_blob", false))
       
       description = "test-schema-description-ruby"
       
       schema = @client.schemas.create_schema(repo.repository_id, description, fields)
       assert_equal(schema.description, description)
       assert_equal(schema.getFields.size, 3)
       assert_not_equal(schema.schema_id, description)
       
       content = Hash.new
       content["test_string"] = "sample value ruby"
       content["test_integer"] = 1233
       
       doc = @client.documents.create_document(schema.schema_id, content)
       assert_not_equal(doc.document_id, "")
       
       description = "test-user-schema-description-ruby"
       fields = []
       fields.push(Field.new("string", "test_string", true))
       fields.push(Field.new("integer", "test_integer", true))
       
       u_schema = @client.user_schemas.create_user_schema(description, fields)
       assert_equal(u_schema.description, description)
       assert_equal(u_schema.getFields.size, 2)
       assert_not_equal(u_schema.user_schema_id, "")
       
       attributes = Hash.new
       attributes["test_string"] = "sample value ruby"
       attributes["test_integer"] = 666
       
       username = "testUsernameRuby"+rand(1..300).to_s
       
       usr = @client.users.create_user(u_schema.user_schema_id, username, "testPassword", attributes)
       assert_equal(usr.user_attributes['test_string'], "sample value ruby")
       assert_equal(usr.user_attributes['test_integer'], 666)
       assert_not_equal(usr.user_id, "")
       
       sleep(3)
       
       sort = []
       sort.push(SortOption.new("test_string", "asc"))
       
       filter = []
       filter.push(FilterOption.new("test_string", "eq", "sample value ruby"))
       filter.push(FilterOption.new("test_integer", "eq", 1233))
       
       docs = @client.search.search_documents(schema.schema_id, "FULL_CONTENT", "and", sort, filter)
       assert_equal(docs.documents.size, 1)
       docs.documents.each do |d|
           assert_equal(d.content['test_string'], "sample value ruby")
           assert_equal(d.content['test_integer'], 1233)
       end
       
       sort = []
       sort.push(SortOption.new("test_string", "asc"))
       
       filter = []
       filter.push(FilterOption.new("test_string", "eq", "sample value ruby"))
       filter.push(FilterOption.new("test_integer", "eq", 666))
       
       users = @client.search.search_users(u_schema.user_schema_id, "FULL_CONTENT", "and", sort, filter)
       assert_equal(users.users.size, 1)
       users.users.each do |u|
           assert_equal(u.user_attributes['test_string'], "sample value ruby")
           assert_equal(u.user_attributes['test_integer'], 666)
       end

        assert_equal(@client.users.delete_user(usr.user_id, true), @success)
        assert_equal(@client.user_schemas.delete_user_schema(u_schema.user_schema_id, true), @success)
        assert_equal(@client.documents.delete_document(doc.document_id, true), @success)
        assert_equal(@client.schemas.delete_schema(schema.schema_id, true), @success)
        assert_equal(@client.repositories.delete_repository(repo.repository_id, true), @success)
   end
end

    #-------------------ACTIVE ALL------------------------#
    
    #    repos = chinoAPI.repositories.list_repositories()
    #    repos.repositories.each do |r|
    #        chinoAPI.repositories.update_repository(r.repository_id, r.description, true)
    #        schemas = chinoAPI.schemas.list_schemas(r.repository_id)
    #        schemas.schemas.each do |s|
    #            chinoAPI.schemas.update_schema(s.schema_id, s.description, s.getFields(), true)
    #            docs = chinoAPI.documents.list_documents(s.schema_id, true)
    #            docs.documents.each do |d|
    #                chinoAPI.documents.update_document(d.document_id, d.content, true)
    #            end
    #        end
    #    end
    #
    #    #-------------------DELETE ALL------------------------#
    
    #    puts "DELETE ALL"
    #
    #    schemas = chinoAPI.user_schemas.list_user_schemas()
    #    schemas.user_schemas.each do |s|
    #        users = chinoAPI.users.list_users(s.user_schema_id)
    #        users.users.each do |u|
    #            puts chinoAPI.users.delete_user(u.user_id, true)
    #        end
    #        puts chinoAPI.user_schemas.delete_user_schema(s.user_schema_id, true)
    #    end
    #
    #    repos = chinoAPI.repositories.list_repositories()
    #    repos.repositories.each do |r|
    #        schemas = chinoAPI.schemas.list_schemas(r.repository_id)
    #        schemas.schemas.each do |s|
    #            docs = chinoAPI.documents.list_documents(s.schema_id, true)
    #            docs.documents.each do |d|
    #                puts chinoAPI.documents.delete_document(d.document_id, true)
    #            end
    #            puts chinoAPI.schemas.delete_schema(s.schema_id, true)
    #        end
    #        puts chinoAPI.repositories.delete_repository(r.repository_id, true)
    #    end
    #
    #    cols = chinoAPI.collections.list_collections()
    #    cols.collections.each do |c|
    #        puts chinoAPI.collections.delete_collection(c.collection_id, true)
    #    end
    #
    #    groups = chinoAPI.groups.list_groups()
    #    groups.groups.each do |g|
    #        puts chinoAPI.groups.delete_group(g.group_id, true)
    #    end
    
    #-------------------APPLICATIONS AND AUTH------------------------#

    #    usr = chinoAPI.auth.loginWithPassword("testUsernames", "testPassword", app.app_id, app.app_secret)
    #    puts usr.access_token + " " + usr.token_type
    #
    #    usr = chinoAPI.auth.refreshToken(usr.refresh_token, app.app_id, app.app_secret)
    #    puts usr.access_token + " " + usr.token_type
    #
    #    chinoAPI = ChinoAPI.new("Bearer ", usr.access_token, url)
    #
    #    puts chinoAPI.auth.logout(usr.access_token, app.app_id, app.app_secret)
    #
    #    chinoAPI = ChinoAPI.new(customer_id, customer_key, url)

#
#    #-------------------BLOBS------------------------#
#    
#    #                puts "BLOBS"
#    #
#    #                filename = "Chino.io-eBook-Health-App-Compliance.pdf"
#    #                path = "app/assets/images/"
#    #
#    #                blob = chinoAPI.blobs.upload_blob(path, filename, doc.document_id, "test_blob")
#    #                puts "document_id: "+blob.document_id.to_s
#    #                puts "blob_id: "+blob.blob_id.to_s
#    #                puts "bytes: "+blob.bytes.to_s
#    #                puts "sha1: "+blob.sha1.to_s
#    #                puts "md5: "+blob.md5.to_s
#    #
#    #                blob = chinoAPI.blobs.get(blob.blob_id, "app/assets/")
#    #                puts "blob_id: "+blob.blob_id.to_s
#    #                puts "path: "+blob.path.to_s
#    #                puts "filename: "+blob.filename.to_s
#    #                puts "size: "+blob.size.to_s
#    #                puts "sha1: "+blob.sha1.to_s
#    #                puts "md5: "+blob.md5.to_s
#    #
#    #                puts "Delete blob: " + chinoAPI.blobs.delete_blob(blob.blob_id, true)
#    
#    puts "Delete group: " + chinoAPI.groups.delete_group(group.group_id, true)
#    puts "Delete user: " + chinoAPI.users.delete_user(usr.user_id, true)
#    puts "Delete user_schema: " + chinoAPI.user_schemas.delete_user_schema(u_schema.user_schema_id, true)
#    puts "Delete collection: " + chinoAPI.collections.delete_collection(col.collection_id, true)
#
#end
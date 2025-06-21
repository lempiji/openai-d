import std.stdio;

import openai;

void main()
{
    auto client = new OpenAIAdminClient();

    // List existing invites
    auto list = client.listInvites(listInvitesRequest(20));
    writeln(list.data.length);

    // Create an invite
    auto created = client.createInvite(inviteRequest("user@example.com", "reader"));
    writeln(created.email);

    // Delete the invite
    auto deleted = client.deleteInvite(created.id);
    writeln(deleted.deleted);
}

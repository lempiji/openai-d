module app;

import std.stdio;
import openai;

void main()
{
    auto client = new OpenAIAdminClient();

    // List existing certificates
    auto list = client.listCertificates();
    writeln(list.data.length);

    if (list.data.length > 0)
    {
        auto id = list.data[0].id;

        // Activate the certificate
        client.activateCertificates(toggleCertificatesRequest([id]));

        // Update the certificate name
        auto name = list.data[0].name;
        client.modifyCertificate(id, modifyCertificateRequest(name));

        // Deactivate the certificate
        client.deactivateCertificates(toggleCertificatesRequest([id]));
    }
}

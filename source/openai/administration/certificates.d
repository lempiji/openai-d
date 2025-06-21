module openai.administration.certificates;

import mir.serde;
import mir.serde : serdeEnumProxy;
import mir.string_map;
import mir.algebraic;

@safe:

@serdeIgnoreUnexpectedKeys
struct CertificateDetails
{
    @serdeKeys("valid_at") long validAt;
    @serdeKeys("expires_at") long expiresAt;
    @serdeOptional string content;
}

@serdeIgnoreUnexpectedKeys
struct Certificate
{
    string object;
    string id;
    string name;
    bool active;
    @serdeKeys("created_at") long createdAt;
    @serdeKeys("certificate_details") CertificateDetails certificateDetails;
}

@serdeIgnoreUnexpectedKeys
struct ListCertificatesResponse
{
    string object;
    Certificate[] data;
    @serdeKeys("first_id") string firstId;
    @serdeKeys("last_id") string lastId;
    @serdeKeys("has_more") bool hasMore;
}

struct ToggleCertificatesRequest
{
    string[] data;
}

/// Convenience constructor for `ToggleCertificatesRequest`.
ToggleCertificatesRequest toggleCertificatesRequest(string[] ids)
{
    auto req = ToggleCertificatesRequest();
    req.data = ids;
    return req;
}

struct ModifyCertificateRequest
{
    string name;
}

/// Convenience constructor for `ModifyCertificateRequest`.
ModifyCertificateRequest modifyCertificateRequest(string name)
{
    auto req = ModifyCertificateRequest();
    req.name = name;
    return req;
}

@serdeIgnoreUnexpectedKeys
struct DeleteCertificateResponse
{
    string object;
    string id;
}


/*

(C)2014, Alexey Sudachen, alexey.sudachen@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Except as contained in this notice, the name of a copyright holder shall not
be used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization of the copyright holder.

*/

#pragma once
#include <windows.h>

#include <cstdint>
#include <cstdlib>
#include <memory>
#include <vector>
#include <array>
#include <string>
#include <functional>
#include <algorithm>

#ifdef USE_OPENSSL
#include <openssl/evp.h>
#include <openssl/x509.h>
#include <openssl/rsa.h>
#include <openssl/sha.h>
#endif

#include <pkcs11/cryptoki.h>

namespace pkcs11
{
	inline std::string hex_bytes(std::vector<uint8_t> bytes);
	inline std::string hex_value(size_t value);
	inline std::string pk11_mechanism_to_string(CK_MECHANISM_TYPE t);

#ifdef USE_OPENSSL
	struct OsslPkeyDeleter { void operator()(EVP_PKEY* pk) {EVP_PKEY_free(pk);} };
	typedef std::unique_ptr<EVP_PKEY, OsslPkeyDeleter> OsslPkey;

	OsslPkey build_ossl_pkey(const std::vector<uint8_t>& exponent, const std::vector<uint8_t>& modulus)
	{
		OsslPkey pk(EVP_PKEY_new());
		RSA* rsa = RSA_new();
		rsa->n = BN_bin2bn(&modulus[0], modulus.size(), 0);
		rsa->e = BN_bin2bn(&exponent[0], exponent.size(), 0);
		EVP_PKEY_assign_RSA(pk.get(), rsa);
		return pk;
	}
#endif

	static const struct
	{
		void operator|(CK_RV rv) const
		{
			if (rv)
				throw std::runtime_error(std::string("PKCS11 error 0x") + hex_value(rv));
		}
	} Die;

	struct Pk11Object: CK_FUNCTION_LIST
	{
		HMODULE _hmod;

		std::vector<uint8_t> QueryBytes(CK_SESSION_HANDLE hndl, CK_OBJECT_HANDLE obj, unsigned t)
		{
			std::vector<uint8_t> bytes;
			CK_ATTRIBUTE attrs;
			attrs.type = t;
			attrs.pValue = 0;
			attrs.ulValueLen = 0;
			Die | C_GetAttributeValue(hndl, obj, &attrs, 1);
			assert(attrs.ulValueLen != 0);
			bytes.reserve(attrs.ulValueLen + 1);
			bytes.resize(attrs.ulValueLen);
			attrs.pValue = &bytes[0];
			Die | C_GetAttributeValue(hndl, obj, &attrs, 1);
			return bytes;
		}

		template < class T >
		T Query(CK_SESSION_HANDLE hndl, CK_OBJECT_HANDLE obj, unsigned t)
		{
			T value;
			CK_ATTRIBUTE attrs;
			attrs.type = t;
			attrs.pValue = &value;
			attrs.ulValueLen = sizeof(T);
			Die | C_GetAttributeValue(hndl, obj, &attrs, 1);
			return value;
		}

		Pk11Object(HMODULE mod) : _hmod(mod)
		{
			memset((CK_FUNCTION_LIST*)this, 0, sizeof(CK_FUNCTION_LIST));
		}
		~Pk11Object()
		{
			if (C_Finalize)
			{
				C_Finalize(0);
			}
			if (_hmod)
			{
				FreeLibrary(_hmod);
			}
		}
	};

	typedef std::shared_ptr<Pk11Object> Pk11;
	struct KeyPairObject;
	typedef std::shared_ptr<KeyPairObject> KeyPair;
	struct SessionObject;
	typedef std::shared_ptr<SessionObject> Session;
	struct SlotObject;
	typedef std::shared_ptr<SlotObject> Slot;
	struct ModuleObject;
	typedef std::shared_ptr<ModuleObject> Module;
	struct MechanismObject;
	typedef std::shared_ptr<MechanismObject> Mechanism;
	struct CertObject;
	typedef std::shared_ptr<CertObject> Cert;


	CK_SESSION_HANDLE handle_of(Session);

	struct CertObject
	{
		Pk11 _pk11;
		Session _ssn;
		std::string _id;
		CK_OBJECT_HANDLE _crt;

		std::vector<uint8_t> _body;

		CertObject(const std::string& id, CK_SESSION_HANDLE crt, Session ssn, Pk11 pk11)
			: _pk11(pk11), _ssn(ssn), _id(id), _crt(crt)
		{
		}

		~CertObject()
		{
		}

		const std::vector<uint8_t> &Body()
		{
			if ( _body.empty() )
			{
				 _body = _pk11->QueryBytes(handle_of(_ssn), _crt, CKA_VALUE);
			}
			return _body;
		}

#ifdef USE_OPENSSL
        const std::vector<uint8_t> Sha1()
        {
            static_assert(SHA_DIGEST_LENGTH == 20,"");
            std::vector<uint8_t> sha1(20);
            const std::vector<uint8_t> &body = Body();
            SHA1(&body[0],body.size(),&sha1[0]);
            return sha1;
        }
#endif

    };

	struct KeyPairObject
	{
		Pk11 _pk11;
		Session _ssn;
		std::string _id;
		CK_OBJECT_HANDLE _pub;
		CK_OBJECT_HANDLE _pri;
		std::vector<uint8_t> _pub_exponent;
		std::vector<uint8_t> _modulus;

		KeyPairObject(const std::string& id, CK_SESSION_HANDLE pub, CK_SESSION_HANDLE pri, Session ssn, Pk11 pk11)
			: _pk11(pk11), _ssn(ssn), _id(id), _pub(pub), _pri(pri)
		{
		}

		~KeyPairObject()
		{
		}

		std::vector<uint8_t> Encrypt(const std::vector<uint8_t>& msg, CK_MECHANISM_TYPE padding = CKM_RSA_PKCS)
		{
#ifdef USE_OPENSSL
			if (padding != CKM_RSA_PKCS && padding != CKM_RSA_X_509 && padding != CKM_RSA_PKCS_OAEP)
				throw std::runtime_error("encrypt/decrypt padding " + pk11_mechanism_to_string(padding) + " is unsupported");
			_QueryData();
			OsslPkey pk = build_ossl_pkey(_pub_exponent, _modulus);
			size_t max_bytes = EVP_PKEY_size(pk.get());
			std::vector<uint8_t> ret(max_bytes);
			if (padding == CKM_RSA_PKCS && msg.size() > max_bytes - 11)
				throw std::runtime_error("message to long, padding "
				                         + pk11_mechanism_to_string(padding)
				                         + " allows up to "
				                         + std::to_string((int64_t)(max_bytes - 11))
				                         + " bytes message");
			else if (padding == CKM_RSA_X_509 && msg.size() > max_bytes)
				throw std::runtime_error("message to long, padding "
				                         + pk11_mechanism_to_string(padding)
				                         + " allows up to "
				                         + std::to_string((int64_t)max_bytes)
				                         + " bytes message");
			else if (padding == CKM_RSA_PKCS_OAEP && msg.size() > max_bytes - 41)
				throw std::runtime_error("message to long, padding "
				                         + pk11_mechanism_to_string(padding)
				                         + " allows up to "
				                         + std::to_string((int64_t)max_bytes - 41)
				                         + " bytes message");
			int rsa_padding = RSA_NO_PADDING;
			if (padding == CKM_RSA_PKCS)
				rsa_padding = RSA_PKCS1_PADDING;
			else if (padding == CKM_RSA_PKCS_OAEP)
				rsa_padding = RSA_PKCS1_OAEP_PADDING;
			int enclen = RSA_public_encrypt(msg.size(), &msg[0], &ret[0], pk->pkey.rsa, rsa_padding);
			if (enclen != ret.size())
				throw std::runtime_error("openssl failed to encrypt given message");
			return ret;
#else
			throw std::runtime_error("encrypt functionality is unavailable");
#endif
		}

		std::vector<uint8_t> Decrypt(const std::vector<uint8_t>& msg, CK_MECHANISM_TYPE padding = CKM_RSA_PKCS)
		{
			static const CK_RSA_PKCS_OAEP_PARAMS oaep_params = {CKM_SHA_1,CKG_MGF1_SHA1,CKZ_DATA_SPECIFIED,0,0};
			CK_MECHANISM mech = {padding, 0, 0};
			if ( padding == CKM_RSA_PKCS_OAEP )
			{ 
				mech.pParameter = (CK_VOID_PTR)&oaep_params;
				mech.ulParameterLen = sizeof(oaep_params);
			};
			_QueryData();
			std::vector<uint8_t> ret(_modulus.size());
			Die | _pk11->C_DecryptInit(handle_of(_ssn), &mech, _pri);
			CK_ULONG count;
			Die | _pk11->C_Decrypt(handle_of(_ssn), (CK_BYTE_PTR)&msg[0], msg.size(), &ret[0], &count);
			ret.resize(count);
			return ret;
		}

		std::vector<uint8_t> Sign(const std::vector<uint8_t>& msg, CK_MECHANISM_TYPE how = CKM_SHA1_RSA_PKCS)
		{
			CK_MECHANISM mech = {how, 0, 0};
			std::array<uint8_t, 512> signat;
			CK_ULONG signat_len = signat.size();
			Die | _pk11->C_SignInit(handle_of(_ssn), &mech, _pri);
			Die | _pk11->C_Sign(handle_of(_ssn), (CK_BYTE_PTR)&msg[0], msg.size(), (CK_BYTE_PTR)&signat[0], &signat_len);
			return std::vector<uint8_t>(signat.begin(), signat.begin() + signat_len);
		}

		bool Verify(const std::vector<uint8_t>& msg, const std::vector<uint8_t>& signature,
		            CK_MECHANISM_TYPE how = CKM_SHA1_RSA_PKCS)
		{
#ifdef USE_OPENSSL
			const EVP_MD* md = EVP_sha1();
			if (how != CKM_SHA1_RSA_PKCS)
				throw std::runtime_error("sign/verify mechanism " + pk11_mechanism_to_string(how) + " is unsupported");
			_QueryData();
			OsslPkey pk = build_ossl_pkey(_pub_exponent, _modulus);
			EVP_MD_CTX md_ctx;
			EVP_VerifyInit(&md_ctx, md);
			EVP_VerifyUpdate(&md_ctx, &msg[0], msg.size());
			if (int status = EVP_VerifyFinal(&md_ctx, &signature[0], signature.size(), pk.get()))
			{
				if (status == 1)
					return true;
				else
					throw std::runtime_error("openssl failed to verify given message's signature");
			}
			else
				return false;
#else
			CK_MECHANISM mech = {how, NULL, 0};
			if (!_pub)
				throw std::runtime_error("there is no public key on backend, verify functionality is unavailable");
			Die | _pk11->C_VerifyInit(handle_of(_ssn), &mech, _pub);
			CK_RV rv = _pk11->C_Verify(
			               handle_of(_ssn),
			               (CK_BYTE_PTR)&msg[0], msg.size(),
			               (CK_BYTE_PTR)&signature[0], signature.size());
			if (rv && rv != CKR_SIGNATURE_INVALID)
				Die | rv;
			else
				return CKR_SIGNATURE_INVALID != rv;
			return false; /*unreached statement*/
#endif
		}

		const std::string& Id() { return _id; }

		void _QueryData()
		{
			CK_OBJECT_HANDLE o = _pub;
			if (!o) o = _pri;
			if (!_modulus.size())
				_modulus = _pk11->QueryBytes(handle_of(_ssn), o, CKA_MODULUS);
			if (!_pub_exponent.size())
				_pub_exponent = _pk11->QueryBytes(handle_of(_ssn), o, CKA_PUBLIC_EXPONENT);
		}

		size_t Bits()
		{
			_QueryData();
			return _modulus.size() * 8;
		}

		const std::vector<uint8_t>& Modulus()
		{
			_QueryData();
			return _modulus;
		}

		const std::vector<uint8_t>& PublicExponent()
		{
			_QueryData();
			return _pub_exponent;
		}

        Cert GetCert();
	};

	typedef std::unique_ptr<void, std::function<void(void*)> > OnExitGuard;
	template < class T >
	OnExitGuard on_exit_scope(T t)
	{
		return OnExitGuard((void*)1, std::function<void(void*)>([t](void*) {t();}));
	}

	struct SessionObject : std::enable_shared_from_this<SessionObject>
	{
		Pk11 _pk11;
		CK_SESSION_HANDLE _hndl;
		CK_SLOT_ID _slt;
		bool _have_to_logout;

		SessionObject(CK_SLOT_ID slot, CK_SESSION_HANDLE hndl, Pk11 pk11)
			: _pk11(pk11), _hndl(hndl), _slt(slot), _have_to_logout(false)
		{
		}

		~SessionObject()
		{
			if (_have_to_logout)
				_pk11->C_Logout(_hndl);
			_pk11->C_CloseSession(_hndl);
		}

		void Login(std::string pin, CK_USER_TYPE user_type = CKU_USER)
		{
			Die | _pk11->C_Login(_hndl, user_type, (CK_UTF8CHAR_PTR)pin.c_str(), pin.length());
			_have_to_logout = true;
		}

		std::vector<uint8_t> _GetID(CK_OBJECT_HANDLE obj)
		{
			return _pk11->QueryBytes(_hndl, obj, CKA_ID);
		}

		void _FindObjects(CK_OBJECT_CLASS cls, std::vector<CK_OBJECT_HANDLE>& objects)
		{
			CK_ATTRIBUTE attrs;
			attrs.type = CKA_CLASS;
			attrs.pValue = &cls;
			attrs.ulValueLen = sizeof(cls);
			CK_OBJECT_HANDLE obj;
			CK_ULONG found;
			objects.clear();
			Die | _pk11->C_FindObjectsInit(_hndl, &attrs, 1);
			auto e = on_exit_scope([this]() {_pk11->C_FindObjectsFinal(_hndl);});
			do
			{
				found = 0;
				Die | _pk11->C_FindObjects(_hndl, &obj, 1, &found);
				if (found) objects.push_back(obj);
			}
			while (found);
		}

		CK_OBJECT_HANDLE _FindObject(CK_OBJECT_CLASS cls, const std::vector<uint8_t>& id)
		{
			CK_ATTRIBUTE attrs[2];
			attrs[0].type = CKA_CLASS;
			attrs[0].pValue = &cls;
			attrs[0].ulValueLen = sizeof(cls);
			attrs[1].type = CKA_ID;
			attrs[1].pValue = (void*)&id[0];
			attrs[1].ulValueLen = id.size();
			CK_OBJECT_HANDLE obj;
			CK_ULONG found;
			Die | _pk11->C_FindObjectsInit(_hndl, attrs, 1);
			auto e = on_exit_scope([this]() {_pk11->C_FindObjectsFinal(_hndl);});
			found = 0;
			Die | _pk11->C_FindObjects(_hndl, &obj, 1, &found);
			return found ? obj : 0;
		}

		std::vector<Cert> ListCerts()
		{
			std::vector<CK_OBJECT_HANDLE> objects;
			std::vector<Cert> ret;

			_FindObjects(CKO_CERTIFICATE, objects);
			for ( auto i = objects.begin(); i != objects.end(); ++i )
			{
				CK_CERTIFICATE_TYPE k = _pk11->Query<CK_CERTIFICATE_TYPE>(_hndl, *i, CKA_CERTIFICATE_TYPE);
				std::vector<uint8_t> id = _GetID(*i);
				ret.push_back(Cert(new CertObject(
						hex_bytes(id),
						*i,
						shared_from_this(),
				    _pk11
					)));
			}

			return ret;
		}

		std::vector<KeyPair> ListKeys()
		{
			std::map<std::string, std::pair<CK_OBJECT_HANDLE, CK_OBJECT_HANDLE>> pairs;
			std::vector<CK_OBJECT_HANDLE> objects;
			std::vector<KeyPair> ret;

			_FindObjects(CKO_PUBLIC_KEY, objects);
			for (auto i = objects.begin(); i != objects.end(); ++i)
			{
				CK_KEY_TYPE k = _pk11->Query<CK_KEY_TYPE>(_hndl, *i, CKA_KEY_TYPE);
				if (k == CKK_RSA)
				{
					std::vector<uint8_t> id = _GetID(*i);
					pairs[hex_bytes(id)].first = *i;
				}
			}
			_FindObjects(CKO_PRIVATE_KEY, objects);
			for (auto i = objects.begin(); i != objects.end(); ++i)
			{
				CK_KEY_TYPE k = _pk11->Query<CK_KEY_TYPE>(_hndl, *i, CKA_KEY_TYPE);
				if (k == CKK_RSA)
				{
					std::vector<uint8_t> id = _GetID(*i);
					pairs[hex_bytes(id)].second = *i;
				}
			}

			typedef std::pair<const std::string, std::pair<CK_OBJECT_HANDLE, CK_OBJECT_HANDLE>> keypair_t;
			auto o = std::back_insert_iterator<std::vector<KeyPair>>(ret);
			std::transform(pairs.begin(), pairs.end(), o, [this](keypair_t & key) -> KeyPair
			{
				KeyPair ret = KeyPair(new KeyPairObject(
				    key.first,
				    key.second.first, key.second.second,
				    shared_from_this(),
				    _pk11));

				return ret;
			});

			return ret;
		}

		CK_SESSION_HANDLE Handle()
		{
			return _hndl;
		}
	};

    inline CK_SESSION_HANDLE handle_of(Session ssn) { return ssn->Handle(); }

    inline Cert KeyPairObject::GetCert()
    {
        printf("handle: %p",_pub?_pub:_pri);
        std::vector<uint8_t> id = _ssn->_GetID(_pub?_pub:_pri);
        printf("id: %d",id.size());
        CK_SESSION_HANDLE  cert = _ssn->_FindObject(CKO_CERTIFICATE,id);
        printf("cert: %p",cert);
        if ( cert )
            return Cert(new CertObject(_id,cert,_ssn,_pk11));
        else
            return Cert(0);
    }

	struct MechanismObject
	{
		Pk11 _pk11;
		CK_SLOT_ID _slt;
		CK_MECHANISM_TYPE _mec;

		MechanismObject(CK_SLOT_ID slot, CK_MECHANISM_TYPE t, Pk11 pk11)
			: _pk11(pk11), _slt(slot), _mec(t)
		{
		}

		std::string ToString()
		{
			return pk11_mechanism_to_string(_mec);
		}

		CK_MECHANISM_TYPE Id()
		{
			return _mec;
		}
	};

	struct SlotObject
	{
		CK_SLOT_ID _slt;
		Pk11 _pk11;

		SlotObject(CK_SLOT_ID slot, Pk11 pk11)
			: _slt(slot), _pk11(pk11)
		{}

		CK_SLOT_ID Id() const
		{
			return _slt;
		}

		Session Open()
		{
			CK_SESSION_HANDLE hndl;
			Die | _pk11->C_OpenSession(_slt, CKF_SERIAL_SESSION, 0, 0, &hndl);
			return Session(new SessionObject(_slt, hndl, _pk11));
		}

		std::vector<Mechanism> ListMechanisms(CK_FLAGS flags = CK_FLAGS(-1))
		{
			std::vector<Mechanism> ret;
			CK_ULONG  count = 0;
			Die | _pk11->C_GetMechanismList(_slt, 0, &count);
			if (count)
			{
				std::vector<CK_MECHANISM_TYPE> lst(count);
				Die | _pk11->C_GetMechanismList(_slt, &lst[0], &count);
				assert(count == lst.size());
                auto end = std::remove_if(lst.begin(), lst.end(),
                    [flags, this](CK_MECHANISM_TYPE t) -> bool
                    {
                        CK_FLAGS f = CKF_ENCRYPT | CKF_DECRYPT | CKF_SIGN | CKF_VERIFY | CKF_WRAP | CKF_UNWRAP;
                        CK_MECHANISM_INFO info;
                        Die | _pk11->C_GetMechanismInfo(_slt, t, &info);
                        if ((info.flags & f) == 0)
                            return true;
                        else if (flags != CK_FLAGS(-1) && (info.flags & flags) != flags)
                            return true;
                        else switch(t)
                        {
                        case CKM_SHA1_RSA_PKCS:
                        case CKM_RSA_PKCS:
                        case CKM_RSA_X_509:
                        case CKM_RSA_PKCS_OAEP:
                            return false;
                        default:
                            return true;
                        }
                    });
				auto o = std::back_insert_iterator<decltype(ret)>(ret);
				std::transform(lst.begin(), end, o, [this](CK_MECHANISM_TYPE t) -> Mechanism
				{
					return Mechanism(new MechanismObject(_slt, t, _pk11));
				});
			}
			return ret;
		}
	};

	struct ModuleObject
	{
		Pk11 _pk11;

		std::vector<Slot> ListSlots()
		{
			std::vector<Slot> ret;
			CK_ULONG count = 0;
			Die | _pk11->C_GetSlotList(1, NULL, &count);
			if (count)
			{
				std::vector<CK_SLOT_ID> lst(count);
				Die | _pk11->C_GetSlotList(1, &lst[0], &count);
				assert(count == lst.size());
				auto o = std::back_insert_iterator<decltype(ret)>(ret);
				std::transform(lst.begin(), lst.end(), o, [this](CK_SLOT_ID id) -> Slot
				{
					return Slot(new SlotObject(id, _pk11));
				});
			}
			return ret;
		}

		ModuleObject(HMODULE hmod)
			: _pk11(new Pk11Object(hmod))
		{}

		void Init()
		{
			CK_FUNCTION_LIST_PTR q;
			CK_RV(*fC_GetFunctionList)(CK_FUNCTION_LIST_PTR_PTR);
            *(FARPROC*)&fC_GetFunctionList = GetProcAddress(_pk11->_hmod, "C_GetFunctionList");
			Die | fC_GetFunctionList(&q);
			(CK_FUNCTION_LIST&)*_pk11 = *q;
			Die | _pk11->C_Initialize(0);
		}
	};

	inline Module _load_modulus(HMODULE mod)
	{
		auto ret = Module(new ModuleObject(mod));
		ret->Init();
		return ret;
	}

	inline Module load_modulus(const std::wstring& dllpath)
	{
		HMODULE mod = LoadLibraryW(dllpath.c_str());
		if (!mod)
			throw std::runtime_error("could not load PKCS11 module ");
		return _load_modulus(mod);
	}

	inline Module load_modulus(const std::string& dllpath)
	{
		HMODULE mod = LoadLibraryA(dllpath.c_str());
		if (!mod)
			throw std::runtime_error("could not load PKCS11 module " + dllpath);
		return _load_modulus(mod);
	}

	inline std::string hex_bytes(std::vector<uint8_t> bytes)
	{
		std::string ret;
		std::for_each(bytes.begin(), bytes.end(), [&ret](uint8_t b)
		{
			static const char tbl[] = "0123456789abcdef";
			ret.insert(ret.end(), 1, tbl[b >> 4]);
			ret.insert(ret.end(), 1, tbl[b & 0x0f]);
		});
		return ret;
	}

	inline std::string hex_value(size_t value)
	{
		std::string ret;
		while (value)
		{
			static const char tbl[] = "0123456789abcdef";
			ret.insert(ret.begin(), tbl[(value) & 0x0f]);
			ret.insert(ret.begin(), tbl[(value >> 4) & 0x0f]);
			value >>= 8;
		}
		if (ret.length() < 8)
			ret.insert(ret.begin(), 8 - ret.length(), '0');
		return ret;
	}

	inline std::string pk11_mechanism_to_string(CK_MECHANISM_TYPE t)
	{
		switch (t)
		{
			case CKM_RSA_PKCS : return "RSA_PKCS";
			case CKM_RSA_9796 : return "RSA_9796";
			case CKM_RSA_X_509 : return "RSA_X_509";
			case CKM_MD2_RSA_PKCS : return "MD2_RSA_PKCS";
			case CKM_MD5_RSA_PKCS : return "MD5_RSA_PKCS";
			case CKM_SHA1_RSA_PKCS : return "SHA1_RSA_PKCS";
			case CKM_SHA256_RSA_PKCS : return "SHA256_RSA_PKCS";
			case CKM_SHA384_RSA_PKCS : return "SHA384_RSA_PKCS";
			case CKM_SHA512_RSA_PKCS : return "SHA512_RSA_PKCS";
			case CKM_RIPEMD128_RSA_PKCS : return "RIPEMD128_RSA_PKCS";
			case CKM_RIPEMD160_RSA_PKCS : return "RIPEMD160_RSA_PKCS";
			case CKM_RSA_PKCS_OAEP : return "RSA_PKCS_OAEP";
			case CKM_RSA_X9_31_KEY_PAIR_GEN : return "RSA_X9_31_KEY_PAIR_GEN";
			case CKM_RSA_X9_31 : return "RSA_X9_31";
			case CKM_SHA1_RSA_X9_31 : return "SHA1_RSA_X9_31";
			case CKM_RSA_PKCS_PSS : return "RSA_PKCS_PSS";
			case CKM_SHA1_RSA_PKCS_PSS : return "SHA1_RSA_PKCS_PSS";
			case CKM_DSA_KEY_PAIR_GEN : return "DSA_KEY_PAIR_GEN";
			case CKM_DSA : return "DSA";
			case CKM_DSA_SHA1 : return "DSA_SHA1";
			case CKM_DH_PKCS_KEY_PAIR_GEN : return "DH_PKCS_KEY_PAIR_GEN";
			case CKM_DH_PKCS_DERIVE : return "DH_PKCS_DERIVE";
			case CKM_X9_42_DH_KEY_PAIR_GEN : return "X9_42_DH_KEY_PAIR_GEN";
			case CKM_X9_42_DH_DERIVE : return "X9_42_DH_DERIVE";
			case CKM_X9_42_DH_HYBRID_DERIVE : return "X9_42_DH_HYBRID_DERIVE";
			case CKM_X9_42_MQV_DERIVE : return "X9_42_MQV_DERIVE";
			case CKM_RC2_KEY_GEN : return "RC2_KEY_GEN";
			case CKM_RC2_ECB : return "RC2_ECB";
			case CKM_RC2_CBC : return "RC2_CBC";
			case CKM_RC2_MAC : return "RC2_MAC";
			case CKM_RC2_MAC_GENERAL : return "RC2_MAC_GENERAL";
			case CKM_RC2_CBC_PAD : return "RC2_CBC_PAD";
			case CKM_RC4_KEY_GEN : return "RC4_KEY_GEN";
			case CKM_RC4 : return "RC4";
			case CKM_DES_KEY_GEN : return "DES_KEY_GEN";
			case CKM_DES_ECB : return "DES_ECB";
			case CKM_DES_CBC : return "DES_CBC";
			case CKM_DES_MAC : return "DES_MAC";
			case CKM_DES_MAC_GENERAL : return "DES_MAC_GENERAL";
			case CKM_DES_CBC_PAD : return "DES_CBC_PAD";
			case CKM_DES2_KEY_GEN : return "DES2_KEY_GEN";
			case CKM_DES3_KEY_GEN : return "DES3_KEY_GEN";
			case CKM_DES3_ECB : return "DES3_ECB";
			case CKM_DES3_CBC : return "DES3_CBC";
			case CKM_DES3_MAC : return "DES3_MAC";
			case CKM_DES3_MAC_GENERAL : return "DES3_MAC_GENERAL";
			case CKM_DES3_CBC_PAD : return "DES3_CBC_PAD";
			case CKM_CDMF_KEY_GEN : return "CDMF_KEY_GEN";
			case CKM_CDMF_ECB : return "CDMF_ECB";
			case CKM_CDMF_CBC : return "CDMF_CBC";
			case CKM_CDMF_MAC : return "CDMF_MAC";
			case CKM_CDMF_MAC_GENERAL : return "CDMF_MAC_GENERAL";
			case CKM_CDMF_CBC_PAD : return "CDMF_CBC_PAD";
			case CKM_MD2 : return "MD2";
			case CKM_MD2_HMAC : return "MD2_HMAC";
			case CKM_MD2_HMAC_GENERAL : return "MD2_HMAC_GENERAL";
			case CKM_MD5 : return "MD5";
			case CKM_MD5_HMAC : return "MD5_HMAC";
			case CKM_MD5_HMAC_GENERAL : return "MD5_HMAC_GENERAL";
			case CKM_SHA_1 : return "SHA_1";
			case CKM_SHA_1_HMAC : return "SHA_1_HMAC";
			case CKM_SHA_1_HMAC_GENERAL : return "SHA_1_HMAC_GENERAL";
			case CKM_SHA256 : return "SHA256";
			case CKM_SHA384 : return "SHA384";
			case CKM_SHA512 : return "SHA512";
			case CKM_RIPEMD128 : return "RIPEMD128";
			case CKM_RIPEMD128_HMAC : return "RIPEMD128_HMAC";
			case CKM_RIPEMD128_HMAC_GENERAL : return "RIPEMD128_HMAC_GENERAL";
			case CKM_RIPEMD160 : return "RIPEMD160";
			case CKM_RIPEMD160_HMAC : return "RIPEMD160_HMAC";
			case CKM_RIPEMD160_HMAC_GENERAL : return "RIPEMD160_HMAC_GENERAL";
			case CKM_CAST_KEY_GEN : return "CAST_KEY_GEN";
			case CKM_CAST_ECB : return "CAST_ECB";
			case CKM_CAST_CBC : return "CAST_CBC";
			case CKM_CAST_MAC : return "CAST_MAC";
			case CKM_CAST_MAC_GENERAL : return "CAST_MAC_GENERAL";
			case CKM_CAST_CBC_PAD : return "CAST_CBC_PAD";
			case CKM_CAST3_KEY_GEN : return "CAST3_KEY_GEN";
			case CKM_CAST3_ECB : return "CAST3_ECB";
			case CKM_CAST3_CBC : return "CAST3_CBC";
			case CKM_CAST3_MAC : return "CAST3_MAC";
			case CKM_CAST3_MAC_GENERAL : return "CAST3_MAC_GENERAL";
			case CKM_CAST3_CBC_PAD : return "CAST3_CBC_PAD";
			case CKM_CAST5_KEY_GEN : return "CAST5_KEY_GEN";
			case CKM_CAST5_ECB : return "CAST5_ECB";
			case CKM_CAST5_CBC : return "CAST5_CBC";
			case CKM_CAST5_MAC : return "CAST5_MAC";
			case CKM_CAST5_MAC_GENERAL : return "CAST5_MAC_GENERAL";
			case CKM_CAST5_CBC_PAD : return "CAST5_CBC_PAD";
			case CKM_RC5_KEY_GEN : return "RC5_KEY_GEN";
			case CKM_RC5_ECB : return "RC5_ECB";
			case CKM_RC5_CBC : return "RC5_CBC";
			case CKM_RC5_MAC : return "RC5_MAC";
			case CKM_RC5_MAC_GENERAL : return "RC5_MAC_GENERAL";
			case CKM_RC5_CBC_PAD : return "RC5_CBC_PAD";
			case CKM_IDEA_KEY_GEN : return "IDEA_KEY_GEN";
			case CKM_IDEA_ECB : return "IDEA_ECB";
			case CKM_IDEA_CBC : return "IDEA_CBC";
			case CKM_IDEA_MAC : return "IDEA_MAC";
			case CKM_IDEA_MAC_GENERAL : return "IDEA_MAC_GENERAL";
			case CKM_IDEA_CBC_PAD : return "IDEA_CBC_PAD";
			case CKM_GENERIC_SECRET_KEY_GEN : return "GENERIC_SECRET_KEY_GEN";
			case CKM_CONCATENATE_BASE_AND_KEY : return "CONCATENATE_BASE_AND_KEY";
			case CKM_CONCATENATE_BASE_AND_DATA : return "CONCATENATE_BASE_AND_DATA";
			case CKM_CONCATENATE_DATA_AND_BASE : return "CONCATENATE_DATA_AND_BASE";
			case CKM_XOR_BASE_AND_DATA : return "XOR_BASE_AND_DATA";
			case CKM_EXTRACT_KEY_FROM_KEY : return "EXTRACT_KEY_FROM_KEY";
			case CKM_SSL3_PRE_MASTER_KEY_GEN : return "SSL3_PRE_MASTER_KEY_GEN";
			case CKM_SSL3_MASTER_KEY_DERIVE : return "SSL3_MASTER_KEY_DERIVE";
			case CKM_SSL3_KEY_AND_MAC_DERIVE : return "SSL3_KEY_AND_MAC_DERIVE";
			case CKM_SSL3_MASTER_KEY_DERIVE_DH : return "SSL3_MASTER_KEY_DERIVE_DH";
			case CKM_TLS_PRE_MASTER_KEY_GEN : return "TLS_PRE_MASTER_KEY_GEN";
			case CKM_TLS_MASTER_KEY_DERIVE : return "TLS_MASTER_KEY_DERIVE";
			case CKM_TLS_KEY_AND_MAC_DERIVE : return "TLS_KEY_AND_MAC_DERIVE";
			case CKM_TLS_MASTER_KEY_DERIVE_DH : return "TLS_MASTER_KEY_DERIVE_DH";
			case CKM_SSL3_MD5_MAC : return "SSL3_MD5_MAC";
			case CKM_SSL3_SHA1_MAC : return "SSL3_SHA1_MAC";
			case CKM_MD5_KEY_DERIVATION : return "MD5_KEY_DERIVATION";
			case CKM_MD2_KEY_DERIVATION : return "MD2_KEY_DERIVATION";
			case CKM_SHA1_KEY_DERIVATION : return "SHA1_KEY_DERIVATION";
			case CKM_PBE_MD2_DES_CBC : return "PBE_MD2_DES_CBC";
			case CKM_PBE_MD5_DES_CBC : return "PBE_MD5_DES_CBC";
			case CKM_PBE_MD5_CAST_CBC : return "PBE_MD5_CAST_CBC";
			case CKM_PBE_MD5_CAST3_CBC : return "PBE_MD5_CAST3_CBC";
			case CKM_PBE_MD5_CAST5_CBC : return "PBE_MD5_CAST5_CBC";
			case CKM_PBE_SHA1_CAST5_CBC : return "PBE_SHA1_CAST5_CBC";
			case CKM_PBE_SHA1_RC4_128 : return "PBE_SHA1_RC4_128";
			case CKM_PBE_SHA1_RC4_40 : return "PBE_SHA1_RC4_40";
			case CKM_PBE_SHA1_DES3_EDE_CBC : return "PBE_SHA1_DES3_EDE_CBC";
			case CKM_PBE_SHA1_DES2_EDE_CBC : return "PBE_SHA1_DES2_EDE_CBC";
			case CKM_PBE_SHA1_RC2_128_CBC : return "PBE_SHA1_RC2_128_CBC";
			case CKM_PBE_SHA1_RC2_40_CBC : return "PBE_SHA1_RC2_40_CBC";
			case CKM_PKCS5_PBKD2 : return "PKCS5_PBKD2";
			case CKM_PBA_SHA1_WITH_SHA1_HMAC : return "PBA_SHA1_WITH_SHA1_HMAC";
			case CKM_KEY_WRAP_LYNKS : return "KEY_WRAP_LYNKS";
			case CKM_KEY_WRAP_SET_OAEP : return "KEY_WRAP_SET_OAEP";
			case CKM_SKIPJACK_KEY_GEN : return "SKIPJACK_KEY_GEN";
			case CKM_SKIPJACK_ECB64 : return "SKIPJACK_ECB64";
			case CKM_SKIPJACK_CBC64 : return "SKIPJACK_CBC64";
			case CKM_SKIPJACK_OFB64 : return "SKIPJACK_OFB64";
			case CKM_SKIPJACK_CFB64 : return "SKIPJACK_CFB64";
			case CKM_SKIPJACK_CFB32 : return "SKIPJACK_CFB32";
			case CKM_SKIPJACK_CFB16 : return "SKIPJACK_CFB16";
			case CKM_SKIPJACK_CFB8 : return "SKIPJACK_CFB8";
			case CKM_SKIPJACK_WRAP : return "SKIPJACK_WRAP";
			case CKM_SKIPJACK_PRIVATE_WRAP : return "SKIPJACK_PRIVATE_WRAP";
			case CKM_SKIPJACK_RELAYX : return "SKIPJACK_RELAYX";
			case CKM_KEA_KEY_PAIR_GEN : return "KEA_KEY_PAIR_GEN";
			case CKM_KEA_KEY_DERIVE : return "KEA_KEY_DERIVE";
			case CKM_FORTEZZA_TIMESTAMP : return "FORTEZZA_TIMESTAMP";
			case CKM_BATON_KEY_GEN : return "BATON_KEY_GEN";
			case CKM_BATON_ECB128 : return "BATON_ECB128";
			case CKM_BATON_ECB96 : return "BATON_ECB96";
			case CKM_BATON_CBC128 : return "BATON_CBC128";
			case CKM_BATON_COUNTER : return "BATON_COUNTER";
			case CKM_BATON_SHUFFLE : return "BATON_SHUFFLE";
			case CKM_BATON_WRAP : return "BATON_WRAP";
			case CKM_ECDSA_KEY_PAIR_GEN : return "ECDSA_KEY_PAIR_GEN";
			case CKM_ECDSA : return "ECDSA";
			case CKM_ECDSA_SHA1 : return "ECDSA_SHA1";
			case CKM_ECDH1_DERIVE : return "ECDH1_DERIVE";
			case CKM_ECDH1_COFACTOR_DERIVE : return "ECDH1_COFACTOR_DERIVE";
			case CKM_ECMQV_DERIVE : return "ECMQV_DERIVE";
			case CKM_JUNIPER_KEY_GEN : return "JUNIPER_KEY_GEN";
			case CKM_JUNIPER_ECB128 : return "JUNIPER_ECB128";
			case CKM_JUNIPER_CBC128 : return "JUNIPER_CBC128";
			case CKM_JUNIPER_COUNTER : return "JUNIPER_COUNTER";
			case CKM_JUNIPER_SHUFFLE : return "JUNIPER_SHUFFLE";
			case CKM_JUNIPER_WRAP : return "JUNIPER_WRAP";
			case CKM_FASTHASH : return "FASTHASH";
			case CKM_AES_KEY_GEN : return "AES_KEY_GEN";
			case CKM_AES_ECB : return "AES_ECB";
			case CKM_AES_CBC : return "AES_CBC";
			case CKM_AES_MAC : return "AES_MAC";
			case CKM_AES_MAC_GENERAL : return "AES_MAC_GENERAL";
			case CKM_AES_CBC_PAD : return "AES_CBC_PAD";
			case CKM_DSA_PARAMETER_GEN : return "DSA_PARAMETER_GEN";
			case CKM_DH_PKCS_PARAMETER_GEN : return "DH_PKCS_PARAMETER_GEN";
			case CKM_X9_42_DH_PARAMETER_GEN : return "X9_42_DH_PARAMETER_GEN";
			default:
				return std::string("unknown-") + hex_value(t);
		}
	}

}

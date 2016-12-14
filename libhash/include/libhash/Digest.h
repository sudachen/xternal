
#pragma once
#include <assert.h>

namespace libhash
{
	template <class Talgo> struct Digest;

	template <
	class CTX,
	      class Digest,
	      void(*_Start)(CTX*),
	      void(*_Update)(CTX*, const void*, size_t),
	      void(*_Finish)(CTX*, void*) >
	struct DigestAlgo
	{
		CTX ctx;

		DigestAlgo()
		{
			_Start(&ctx);
		}

		void Update(const void* bytes, size_t count)
		{
			_Update(&ctx, bytes, count);
		}

		void Finish(void* dgst, size_t dgst_size)
		{
			assert(dgst_size == Digest::BytesRequired);
			_Finish(&ctx, dgst);
		}

		void Finish(typename Digest::Type& dgst)
		{
			_Finish(&ctx, &dgst[0]);
		}
	};

	template <class Talgo>
	struct DigestFunction
	{
		void operator()(const void* bytes, size_t count, void* dgst, size_t dgst_size) const
		{
			assert(dgst_size == Digest<Talgo>::BytesRequired);
			Talgo algo;
			algo.Update(bytes, count);
			algo.Finish(dgst, dgst_size);
		}

		typename Digest<Talgo>::Type operator()(const void* bytes, size_t count) const
		{
			typename Digest<Talgo>::Type ret;
			operator()(bytes, count, &ret, sizeof(ret));
			return ret;
		}

		void operator()(const void* bytes, size_t count, typename Digest<Talgo>::Type& ret) const
		{
			operator()(bytes, count, &ret, sizeof(ret));
		}
	};

	template <
		class CTX,
	      class Digest,
	      void(*_Start)(CTX*, const void*, size_t),
	      void(*_Update)(CTX*, const void*, size_t),
	      void(*_Finish)(CTX*, void*) >
	struct DigestHmacAlgo
	{
		CTX ctx;

		DigestHmacAlgo(const void* key, size_t key_len)
		{
			_Start(&ctx);
		}

		void Update(const void* bytes, size_t count)
		{
			_Update(&ctx, bytes, count);
		}

		void Finish(void* dgst, size_t dgst_size)
		{
			assert(dgst_size == Digest::BytesRequired);
			_Finish(&ctx, dgst);
		}

		void Finish(typename Digest::Type& dgst)
		{
			_Finish(&ctx, &dgst[0]);
		}
	};

	template <class Talgo>
	struct DigestHmacFunction
	{
		void operator()(const void* key, size_t key_len, const void* bytes, size_t count, void* dgst, size_t dgst_size) const
		{
			assert(dgst_size == Digest<Talgo>::BytesRequired);
			Talgo algo(key, key_len);
			algo.Update(bytes, count);
			algo.Finish(dgst, dgst_size);
		}

		typename Digest<Talgo>::Type operator()(const void* key, size_t key_len, const void* bytes, size_t count) const
		{
			typename Digest<Talgo>::Type ret;
			operator()(key, key_len, bytes, count, &ret, sizeof(ret));
			return ret;
		}

		void operator()(const void* key, size_t key_len, const void* bytes, size_t count,
		                typename Digest<Talgo>::Type& ret) const
		{
			operator()(key, key_len, bytes, count, &ret, sizeof(ret));
		}
	};

}

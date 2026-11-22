package com.elitesync.network

import android.util.Base64
import com.elitesync.BuildConfig
import java.io.IOException
import java.net.Proxy
import java.security.KeyStore
import java.security.cert.CertificateFactory
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManagerFactory
import javax.net.ssl.X509TrustManager
import okhttp3.HttpUrl.Companion.toHttpUrl
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object ApiClient {
    private const val FALLBACK_BASE_URL = "https://slowdate.top/"
    private val baseUrl = if (BuildConfig.ELITESYNC_V2_FUNCTION_BUILD) {
        val expectedOrigin = if (BuildConfig.ELITESYNC_V2_STAGING_LOGIN_BUILD) {
            "https://127.0.0.1:18446/"
        } else {
            "https://127.0.0.1:18444/"
        }
        BuildConfig.API_BASE_URL.also { check(it == expectedOrigin) }
    } else {
        BuildConfig.API_BASE_URL.ifBlank { FALLBACK_BASE_URL }
    }

    val service: ApiService by lazy {
        val builder = OkHttpClient.Builder()
        if (BuildConfig.ELITESYNC_V2_FUNCTION_BUILD) {
            val origin = baseUrl.toHttpUrl()
            val der = Base64.decode(BuildConfig.ELITESYNC_V2_FUNCTION_CERTIFICATE, Base64.DEFAULT)
            val certificate = CertificateFactory.getInstance("X.509").generateCertificate(der.inputStream())
            val keys = KeyStore.getInstance(KeyStore.getDefaultType()).apply {
                load(null, null)
                setCertificateEntry("fixture", certificate)
            }
            val trust = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm())
            trust.init(keys)
            val manager = trust.trustManagers.filterIsInstance<X509TrustManager>().single()
            val ssl = SSLContext.getInstance("TLS").apply { init(null, arrayOf(manager), null) }
            builder.sslSocketFactory(ssl.socketFactory, manager)
                .proxy(Proxy.NO_PROXY)
                .followRedirects(false)
                .followSslRedirects(false)
                .addInterceptor { chain ->
                    val url = chain.request().url
                    if (url.scheme != origin.scheme || url.host != origin.host || url.port != origin.port) {
                        throw IOException("Untrusted V2 function endpoint")
                    }
                    chain.proceed(chain.request())
                }
        } else {
            builder.dns(DomainDns)
        }
        val client = builder.build()
        Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(ApiService::class.java)
    }
}

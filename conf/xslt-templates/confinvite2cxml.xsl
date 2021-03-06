<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:str="http://exslt.org/strings"
   xmlns:exslt="http://exslt.org/common"
   xmlns:sccp="http://chan-sccp.net" version="1.0" exclude-result-prefixes="sccp"
>

  <xsl:param name="locales" select="'da, nl, de;q=0.9, en-gb;q=0.8, en;q=0.7'"/>
  <xsl:param name="translationFile" select="'./translations.xml'"/>
  <xsl:param name="locale"><xsl:call-template name="findLocale"/></xsl:param>
  
  <xsl:template name="findLocale">
    <xsl:param name="locales" select='$locales'/>
    <xsl:choose>
      <xsl:when test="document($translationFile)//sccp:translation and not($locales = '')">
        <xsl:variable name="translationNodeSet">
        <translations>
          <xsl:for-each select="str:tokenize($locales, ' -_,')">
            <xsl:variable name="testLocale" select="substring-before(concat(., ';'), ';')"/>
            <xsl:if test="$testLocale = 'en' or document($translationFile)//sccp:translation[@locale=$testLocale]">
            <translation><xsl:value-of select="$testLocale"/></translation>
            </xsl:if>
          </xsl:for-each>
        </translations>
        </xsl:variable>
        <xsl:for-each select="exslt:node-set($translationNodeSet)/translations/translation">
          <xsl:if test="position() = 1">
            <xsl:value-of select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>en</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="translate">
    <xsl:param name="key"/>
    <xsl:param name="locale" select='$locale'/>
    <xsl:choose>
      <xsl:when test="not(document($translationFile)//sccp:translation[@locale=$locale]) or $locale = 'en'">
        <xsl:value-of select="$key"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="document($translationFile)//sccp:translation[@locale=$locale]/entry[@key=$key]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="/error">
    <xsl:if test="errorno &gt; 0">
      <CiscoIPPhoneText>
        <Title>An Error Occurred</Title>
        <Text><xsl:value-of select="errorno"/>: 
    <xsl:call-template name="translate"><xsl:with-param name="key" select="concat('errorno-',errorno)"/></xsl:call-template></Text>
      </CiscoIPPhoneText>
    </xsl:if>
  </xsl:template>

<xsl:template match="/device">
<CiscoIPPhoneInput>
<xsl:if test="protocolversion &gt; 15">
<xsl:attribute name="appId"><xsl:value-of select="conference/appId"/></xsl:attribute>
</xsl:if>
<Title><xsl:call-template name="translate"><xsl:with-param name="key" select="'Conference'"/></xsl:call-template><xsl:text> </xsl:text><xsl:value-of select="conference/id"/></Title>
<Prompt><xsl:call-template name="translate"><xsl:with-param name="key" select="'Enter Phone# to Invite'"/></xsl:call-template></Prompt>
<URL><xsl:value-of select="server_url"/>?handler=<xsl:value-of select="handler"/>&amp;<xsl:value-of select="uri"/>&amp;action=PROCESS_INVITE</URL>
<xsl:apply-templates select="conference"/>
</CiscoIPPhoneInput>
</xsl:template>

<xsl:template match="conference">
<InputItem>
<DisplayName><xsl:call-template name="translate"><xsl:with-param name="key" select="'Phone Number'"/></xsl:call-template></DisplayName>
<QueryStringParam>NUMBER</QueryStringParam>
<InputFlags>T</InputFlags>
</InputItem>
<InputItem>
<DisplayName><xsl:call-template name="translate"><xsl:with-param name="key" select="'Name'"/></xsl:call-template></DisplayName>
<QueryStringParam>NAME</QueryStringParam>
<InputFlags>T</InputFlags>
</InputItem>
</xsl:template>

</xsl:stylesheet>

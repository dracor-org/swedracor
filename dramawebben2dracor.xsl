<?xml version="1.0" encoding="utf-8"?>
<!--
  Note: In order to preserve the formatting of the original documents as far as
  possible, this stylesheet manually indents the added elements.
-->
<xsl:stylesheet version="2.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">

  <!-- We use indent=no to prevent Saxon to add unnecessary newlines. -->
  <xsl:output
    method="xml"
    encoding="UTF-8"
    omit-xml-declaration="no"
    indent="no"
  />

  <xsl:variable name="ids" select="document('ids.xml')"/>
  <xsl:variable name="dwid" select="//tei:text/@xml:id"/>
  <xsl:variable
    name="dracor-id"
    select="$ids//play[@dramawebben=$dwid]/@dracor"
  />
  <xsl:variable
    name="play-wikidata-id"
    select="$ids//play[@dramawebben=$dwid]/@wikidata"
  />
  <xsl:variable
    name="editorial-cast"
    select="/tei:TEI//tei:div[@type='editorial']//tei:listPerson[@type='cast']"
  />

  <xsl:template match="/">
    <xsl:text>&#10;</xsl:text>
    <xsl:processing-instruction name="xml-stylesheet">type="text/css" href="../css/tei.css"</xsl:processing-instruction>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="/tei:TEI"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- set xml:lang -->
  <xsl:template match="tei:TEI">
    <TEI xml:lang="sv">
      <xsl:text>&#10;  </xsl:text>
      <xsl:apply-templates select="/tei:TEI/*"/>
      <xsl:text>&#10;</xsl:text>
    </TEI>
  </xsl:template>

  <!-- remove xml:id from castList roles -->
  <xsl:template match="tei:role/@xml:id"></xsl:template>
  <!-- remove xml:id from castList roleGroup -->
  <xsl:template match="tei:roleGroup/@xml:id"></xsl:template>

  <!-- remove xml:id from tei:text -->
  <xsl:template match="tei:text[@xml:id]">
    <xsl:text>&#10;  </xsl:text>
    <text>
      <xsl:apply-templates/>
    </text>
  </xsl:template>

  <!-- add DraCor ID, wikidata ID for play -->
  <xsl:template match="tei:publicationStmt">
    <publicationStmt>
      <xsl:apply-templates/>
      <xsl:text>  </xsl:text>
      <idno type="dramawebben">
        <xsl:value-of select="$dwid"/>
      </idno>
      <xsl:text>&#10;        </xsl:text>
      <idno type="dracor" xml:base="https://dracor.org/id/">
        <xsl:value-of select="$dracor-id"/>
      </idno>
      <xsl:if test="$play-wikidata-id">
        <xsl:text>&#10;        </xsl:text>
        <idno type="wikidata" xml:base="https://www.wikidata.org/entity/">
          <xsl:value-of select="$play-wikidata-id"/>
        </idno>
      </xsl:if>
      <xsl:text>&#10;      </xsl:text>
    </publicationStmt>
  </xsl:template>

  <!-- add wikidata ID for author -->
  <xsl:template match="tei:titleStmt/tei:author">
    <xsl:variable name="id" select="./@xml:id"/>
    <xsl:variable name="name" select="normalize-space(tei:persName)"/>
    <xsl:variable
      name="wikidata-id"
      select="$ids//author[@dramawebben=$id or @name=$name]/@wikidata"
    />
    <author>
      <xsl:if test="$wikidata-id">
        <xsl:attribute name="key">
          <xsl:text>wikidata:</xsl:text>
          <xsl:value-of select="$wikidata-id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </author>
  </xsl:template>

  <!-- create particDesc -->
  <xsl:template match="tei:profileDesc">
    <xsl:variable name="castList" select="/tei:TEI//tei:castList"/>
    <profileDesc>
      <xsl:apply-templates/>
      <xsl:text>  </xsl:text>
      <particDesc>
        <xsl:text>&#10;        </xsl:text>
        <listPerson>
        <xsl:for-each select="/tei:TEI//tei:sp[@who]">
          <xsl:variable name="sp" select="."/>
          <xsl:variable
            name="whos" select="tokenize(normalize-space(@who), '\s+')"/>
          <xsl:for-each select="$whos">
            <xsl:variable name="who" select="substring(., 2)"/>
            <xsl:if test="not(
              $sp/preceding::tei:sp[tokenize(@who) = concat('#', $who)]
            )">

              <xsl:variable
                name="role"
                select="$castList//tei:role[@xml:id = $who]"/>
              <xsl:variable
                name="roleGroup"
                select="$castList//tei:roleGroup[@xml:id = $who]"/>

              <xsl:text>&#10;          </xsl:text>

              <xsl:choose>
                <!-- ROLE -->
                <xsl:when test="$role">
                  <xsl:variable name="ref">
                    <xsl:choose>
                      <xsl:when test="$role/tei:persName/@ref">
                        <xsl:value-of select="$role/tei:persName/@ref"/>
                      </xsl:when>
                      <xsl:when test="$role/@corresp">
                        <xsl:value-of select="$role/@corresp"/>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:variable>
                  <xsl:variable
                    name="person"
                    select="$editorial-cast//tei:person[@xml:id=substring($ref, 2)]"
                  />
                  <xsl:variable
                    name="editorial-name"
                    select="$person/tei:persName[1]"
                  />
                  <xsl:variable name="sex" select="$person/@sex"/>

                  <xsl:text>&#10;          </xsl:text>
                  <person>
                    <xsl:attribute name="xml:id">
                      <xsl:value-of select="$who"/>
                    </xsl:attribute>
                    <xsl:if test="$sex">
                      <xsl:attribute name="sex">
                        <xsl:value-of select="upper-case($sex)"/>
                      </xsl:attribute>
                    </xsl:if>
                    <xsl:text>&#10;            </xsl:text>
                    <persName>
                      <xsl:choose>
                        <xsl:when test="$editorial-name">
                          <xsl:value-of
                            select="normalize-space($editorial-name)"
                          />
                          <!-- <xsl:comment>editorial</xsl:comment> -->
                        </xsl:when>
                        <xsl:when test="$role/tei:persName">
                          <xsl:value-of
                            select="normalize-space($role/tei:persName)"
                          />
                          <!-- <xsl:comment>castList</xsl:comment> -->
                        </xsl:when>
                        <xsl:when test="not($role/text())">
                          <xsl:value-of
                            select="normalize-space($sp/tei:speaker)"
                          />
                          <!-- <xsl:comment>speaker</xsl:comment> -->
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="normalize-space($role)"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </persName>
                    <xsl:text>&#10;          </xsl:text>
                  </person>
                </xsl:when>

                <!-- ROLE GROUP -->
                <xsl:when test="$roleGroup">
                  <xsl:variable name="ref" select="$roleGroup/@corresp"/>
                  <xsl:variable
                    name="group"
                    select="$editorial-cast//tei:personGrp[@xml:id=substring($ref, 2)]"
                  />
                  <xsl:variable
                    name="editorial-name"
                    select="$group/tei:persName[1]"
                  />
                  <xsl:variable name="sex" select="$group/@sex"/>
                  <xsl:variable name="name">
                    <xsl:choose>
                      <xsl:when test="$roleGroup/tei:roleDesc">
                        <xsl:value-of select="$roleGroup/tei:roleDesc"/>
                      </xsl:when>
                      <xsl:when test="$editorial-name">
                        <xsl:value-of select="$editorial-name"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="$sp/tei:speaker"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <personGrp>
                    <xsl:attribute name="xml:id">
                      <xsl:value-of select="$who"/>
                    </xsl:attribute>
                    <xsl:if test="$sex">
                      <xsl:attribute name="sex">
                        <xsl:value-of select="upper-case($sex)"/>
                      </xsl:attribute>
                    </xsl:if>
                    <xsl:text>&#10;            </xsl:text>
                    <name>
                      <xsl:value-of select="normalize-space($name)"/>
                    </name>
                    <xsl:text>&#10;          </xsl:text>
                  </personGrp>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:comment>
                    <xsl:text>unknown speaker: </xsl:text>
                    <xsl:value-of select="$who"/>
                  </xsl:comment>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
        <xsl:text>&#10;        </xsl:text>
        </listPerson>
        <xsl:text>&#10;      </xsl:text>
      </particDesc>
      <xsl:text>&#10;    </xsl:text>
    </profileDesc>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- add 'originalSource' dates -->
  <xsl:template match="tei:sourceDesc">
    <xsl:variable
      name="print"
      select="(.//tei:biblStruct/tei:monogr/tei:imprint/tei:date/@when)[1]"
    />
    <sourceDesc>
      <xsl:apply-templates/>
      <xsl:if test="$print">
        <xsl:text>  </xsl:text>
        <bibl type="originalSource">
            <xsl:text>&#10;          </xsl:text>
            <date type="print" when="{$print}"/>
            <xsl:text>&#10;        </xsl:text>
        </bibl>
        <xsl:text>&#10;      </xsl:text>
      </xsl:if>
    </sourceDesc>
  </xsl:template>
</xsl:stylesheet>

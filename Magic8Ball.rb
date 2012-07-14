# -*- coding: utf-8 -*-

###############################################################################
#     Copyright © 2012 Hector Sanjuan                                         #
#                                                                             #
#     This file is part of Magic8Ball.                                        #
#                                                                             #
#     Magic8Ball is free software: you can redistribute it and/or modify      #
#     it under the terms of the GNU General Public License as published by    #
#     the Free Software Foundation, either version 3 of the License, or       #
#     (at your option) any later version.                                     #
#                                                                             #
#     Magic8Ball is distributed in the hope that it will be useful,           #
#     but WITHOUT ANY WARRANTY; without even the implied warranty of          #
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           #
#     GNU General Public License for more details.                            #
#                                                                             #
#     You should have received a copy of the GNU General Public License       #
#     along with Magic8Ball.  If not, see <http://www.gnu.org/licenses/>.     #
#                                                                             #
###############################################################################


# This class represents a typical Magic 8 Ball. See:
# http://en.wikipedia.org/wiki/Magic_8-Ball
class Magic8Ball

    attr_reader :lang

    # Magic ball answers - localized
    ANSWERS = {
        :en => [
                "It is certain",
                "It is decidedly so",
                "Without a doubt",
                "Yes, definitely",
                "You may rely on it",
                "As I see it, yes",
                "Most likely",
                "Outlook good",
                "Yes",
                "Signs point to yes",
                "Reply hazy, try again",
                "Ask again later",
                "Better not tell you now",
                "Cannot predict now",
                "Concentrate and ask again",
                "Don't count on it",
                "My reply is no",
                "My sources say no",
                "Outlook not so good",
                "Very doubtful",
               ],
        :es => [
                "Es cierto",
                "Es decididamente así",
                "Sin duda alguna",
                "Sí, definitivamente",
                "Puedes contar con ello",
                "Tal y como lo veo, sí",
                "Es lo más probable",
                "Pronóstico favorable",
                "Sí",
                "Todo apunta a que sí",
                "Respuesta vaga, vuelve a intentarlo",
                "Pregunta más tarde",
                "Mejor no decírtelo ahora",
                "No puedo predecirlo ahora",
                "Concéntrate y pregunta de nuevo",
                "No cuentes con ello",
                "Mi respuesta es no",
                "Mis fuentes me dicen que no",
                "Pronóstico poco favorable",
                "Muy dudoso",
               ]
    }

    # Ask a new question to the magic ball
    # @param [Hash] Options: currently :lang.
    def self.ask(opts = {})
        lang = opts[:lang] && ANSWERS[opts[:lang]] ? opts[:lang] : :en
        ANSWERS[lang][rand(ANSWERS[lang].size)]
    end
end
